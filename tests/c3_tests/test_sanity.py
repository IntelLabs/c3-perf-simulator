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

# TODO: change this once there's an se.py option
useC3 = lambda b: "-e c3_enable.env" if b else ""


@pytest.mark.it("test-progs/hello still works without C3")
def test_hello_icelake_no_c3():
    gem5_cmd = " ".join(
        [
            gem5_exec,
            config_py,
            icelake_config,
            useC3(False),
            "-c tests/test-progs/hello/bin/x86/linux/hello",
        ]
    )
    gem5_output = subprocess.check_output(
        gem5_cmd, shell=True, cwd=gem5_dir
    ).decode("utf-8")
    assert "Hello world!" in gem5_output


@pytest.mark.it("test-progs/hello still works *with* C3")
def test_hello_icelake_with_c3():
    gem5_cmd = " ".join(
        [
            gem5_exec,
            config_py,
            icelake_config,
            useC3(True),
            "-c tests/test-progs/hello/bin/x86/linux/hello",
        ]
    )
    gem5_output = subprocess.check_output(
        gem5_cmd, shell=True, cwd=gem5_dir
    ).decode("utf-8")
    assert "Hello world!" in gem5_output


# this does assume NO modifications to the spectre demo!
# in particular, no pointer enc/dec built into main()
@pytest.mark.it("SafeSide Spectre v1 PHT succeeds on base gem5")
@pytest.mark.skip(reason="Not needed for this deliverable")
def test_spectre_pht_icelake():
    gem5_cmd = " ".join(
        [
            gem5_exec,
            config_py,
            icelake_config,
            useC3(False),
            "-c tests/c3_tests/c3-safeside/build/demos/spectre_v1_pht_sa",
        ]
    )
    gem5_output = subprocess.check_output(
        gem5_cmd, shell=True, cwd=gem5_dir
    ).decode("utf-8")
    assert "s3kr3t" in gem5_output


@pytest.mark.it(
    "c3_tests/hello_c3 works -- so ccptrenc gets executed and pointer decryption works"
)
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
