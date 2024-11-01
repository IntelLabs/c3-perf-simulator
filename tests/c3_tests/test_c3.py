import subprocess
import pytest
import re

gem5_dir = "../.."
gem5_exec = "build/X86/gem5.opt"
debug_flags = "--debug-flags=LSQUnit"
config_py = "configs/example/se.py"
icelake_config = "--cpu-type=O3_X86_icelake_1 --caches"
safeside_dir = ""
stats_file = "../../m5out/stats.txt"
DATA_KEYSTREAM_GENERATION_DELAY = 4
useC3 = lambda b: "-e c3_no_wrap_enable.env" if b else ""


"""
This file tests the actual functionality of C3.
"""


@pytest.mark.it(
    "c3_tests/hello_c3 works -- so ccptrenc gets executed and pointer decryption works"
)
@pytest.mark.skip(reason="Pointer encryption disabled in this release")
def test_ccptrenc():
    gem5_cmd = " ".join(
        [
            gem5_exec,
            config_py,
            icelake_config,
            useC3(True),
            "-c tests/c3_tests/hello_c3ctest",
        ]
    )
    gem5_output = subprocess.check_output(
        gem5_cmd, shell=True, cwd=gem5_dir
    ).decode("utf-8")
    assert "Hi!" in gem5_output
    assert "Bye!" in gem5_output
    out_lines = gem5_output.strip().split("\n")
    addr_re = re.compile(r"Array \d @ ([0-9a-f]{16})")
    addrs = [
        int(m.group(1), 16)
        for m in [re.match(addr_re, line) for line in out_lines]
        if m
    ]
    # bits 57-34 should not be the same
    unique_high_bits = set([format(a, "#016b")[::-1][34:58] for a in addrs])
    assert len(addrs) == len(unique_high_bits)


@pytest.mark.it(
    "c3_tests/dataEncDec_c3ctest works -- Data Encryption/Decryption Basic Unit Test (Includes Only CAs)."
)
def test_dataEncDec_Basic():
    gem5_cmd = " ".join(
        [
            gem5_exec,
            config_py,
            icelake_config,
            useC3(True),
            "-c tests/c3_tests/dataEncDec_c3ctest",
        ]
    )
    gem5_output = subprocess.check_output(
        gem5_cmd, shell=True, cwd=gem5_dir
    ).decode("utf-8")
    assert "SUCCESS!" in gem5_output


@pytest.mark.it(
    "c3_tests/dataEncDec works -- Data Encryption/Decryption Advanced Unit Test (Includes Mixture of CAs and LAs)."
)
@pytest.mark.skip(reason="Build problems due to GLIBC changes")
def test_dataEncDec_Advanced():
    gem5_cmd = " ".join(
        [
            gem5_exec,
            config_py,
            icelake_config,
            useC3(True),
            "-c tests/c3_tests/dataEncDec",
        ]
    )
    gem5_output = subprocess.check_output(
        gem5_cmd, shell=True, cwd=gem5_dir
    ).decode("utf-8")
    assert "Write Data using LA: Hi, C3!" in gem5_output
    assert "Read Data using LA: Hi, C3!" in gem5_output
    assert "LA -> LA : SUCCESS" in gem5_output
    assert "Read Data using CA: garbled data!" in gem5_output
    assert "LA -> CA : SUCCESS" in gem5_output
    assert "Write Data using CA: S3cr3t!" in gem5_output
    assert "Read Data using CA with the same metadata: S3cr3t!" in gem5_output
    assert "CA -> CA : SUCCESS" in gem5_output
    assert "Read Data using LA: garbled data!" in gem5_output
    assert "CA -> LA : SUCCESS" in gem5_output
    assert (
        "Read Data using CA with the different metadata: garbled data!"
        in gem5_output
    )
    assert "CA1 -> CA2 : SUCCESS" in gem5_output


@pytest.mark.it(
    "c3_tests/dataKeyGen_c3 works -- Data Keystream Generation Functionality and Timing Unit Test."
)
def test_dataKeyGen():
    gem5_cmd = " ".join(
        [
            gem5_exec,
            debug_flags,
            config_py,
            icelake_config,
            useC3(True),
            "-c tests/c3_tests/dataEncDec_c3ctest",
        ]
    )
    gem5_output = subprocess.check_output(
        gem5_cmd, shell=True, cwd=gem5_dir
    ).decode("utf-8")

    initialize_pattern = re.compile(
        r"\d+: system\.cpu\.iew\.lsq: Initialize data keystream generation for Inst \[sn:\d+\]"
    )
    complete_pattern = re.compile(
        r"\d+: system\.cpu\.iew\.lsq: Complete data keystream generation for Inst \[sn:\d+\]"
    )
    initialize_lines = initialize_pattern.findall(gem5_output)
    complete_lines = complete_pattern.findall(gem5_output)

    # Assertion 1: Assert the number of issued data keystream generation events
    with open(stats_file, "r") as sf:
        lines = sf.readlines()
        for line in lines:
            parts = line.strip().split()
            if line.startswith("system.cpu.lsq0.rescheduledLoadsCA"):
                rescheduledLoadsCA = int(parts[1])
            if line.startswith("system.cpu.lsq0.squashedLoadsCA"):
                squashedLoadsCA = int(parts[1])
            if line.startswith("system.cpu.lsq0.squashedStoresCA "):
                squashedStoresCA = int(parts[1])
            if line.startswith("system.cpu.commit.cryptoAddrCommittedInsts "):
                cryptoAddrCommittedInsts = int(parts[1])
        expected_dataKeyGenIssue = (
            cryptoAddrCommittedInsts
            + squashedStoresCA
            + squashedLoadsCA
            + rescheduledLoadsCA
        )
        assert expected_dataKeyGenIssue == len(initialize_lines)

    # Assertion 2: Assert every initialized data keystream should have a matching completion
    assert len(initialize_lines) == len(complete_lines)

    # Assertion 3: Assert data keystream generation latency
    for i in range(len(complete_lines)):
        match = re.search(r"(\d+)", initialize_lines[i])
        initialize_ticks = int(match.group(1))
        match = re.search(r"(\d+)", complete_lines[i])
        complete_ticks = int(match.group(1))
        assert (
            complete_ticks - initialize_ticks
            == 500 * DATA_KEYSTREAM_GENERATION_DELAY
        )


blowfish_key = "1234567890abcdeffedcba0987654321"


@pytest.mark.it(
    "Blowfish works correctly with C3 enabled, and it takes longer with C3 enabled"
)
def test_blowfish_works():
    # do a native blowfish run to get a golden outfile
    subprocess.run(
        [
            "./mibench/security/blowfish/bf",
            "e",
            "./mibench/security/blowfish/input_small.asc",
            "./bf_golden.enc",
            blowfish_key,
        ]
    )
    # do a c3 blowfish run in gem5
    gem5_c3_cmd = " ".join(
        [
            gem5_exec,
            "--outdir=blowfish_c3",
            config_py,
            icelake_config,
            useC3(True),
            "-c tests/c3_tests/mibench/security/blowfish/bf",
            '-o "e tests/c3_tests/mibench/security/blowfish/input_small.asc',
            "tests/c3_tests/bf_c3.enc",
            blowfish_key,
            '"',
        ]
    )
    c3_output = subprocess.check_output(
        gem5_c3_cmd, shell=True, cwd=gem5_dir
    ).decode("utf-8")
    # do a no-c3 run in gem5
    gem5_no_c3_cmd = " ".join(
        [
            gem5_exec,
            "--outdir=blowfish_noc3",
            config_py,
            icelake_config,
            useC3(False),
            "-c tests/c3_tests/mibench/security/blowfish/bf",
            '-o "e tests/c3_tests/mibench/security/blowfish/input_small.asc',
            "tests/c3_tests/bf_noc3.enc",
            blowfish_key,
            '"',
        ]
    )
    no_c3_output = subprocess.check_output(
        gem5_no_c3_cmd, shell=True, cwd=gem5_dir
    ).decode("utf-8")
    # compare both output files to the golden one (no diff)
    c3_diff = subprocess.check_output(
        "diff bf_c3.enc bf_golden.enc", shell=True
    ).decode("utf-8")
    print(f"C3 diff: {c3_diff}")
    noc3_diff = subprocess.check_output(
        "diff bf_noc3.enc bf_golden.enc", shell=True
    ).decode("utf-8")
    assert c3_diff == ""
    print(f"No C3 diff: {noc3_diff}")
    assert noc3_diff == ""
    # c3 run should have a higher cycle count than no-c3
    cycle_regex = r"@ tick (\d+) because"
    c3_match = re.search(cycle_regex, c3_output)
    c3_ticks = int(c3_match.group(1))
    no_c3_match = re.search(cycle_regex, no_c3_output)
    no_c3_ticks = int(no_c3_match.group(1))
    assert no_c3_ticks < c3_ticks
