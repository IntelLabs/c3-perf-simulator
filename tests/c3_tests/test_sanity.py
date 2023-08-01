import subprocess
import pytest
import re

gem5_dir = "../.."
gem5_exec = "build/X86/gem5.opt configs/example/se.py"
icelake_config = "--cpu-type=O3_X86_icelake_1 --caches"
safeside_dir = ""

# TODO: change this once there's an se.py option
useC3 = lambda b: "-e c3_enable.env" if b else ""


@pytest.mark.it("test-progs/hello still works without C3")
def test_hello_icelake_no_c3():
    gem5_cmd = " ".join(
        [
            gem5_exec,
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
def test_spectre_pht_icelake():
    gem5_cmd = " ".join(
        [
            gem5_exec,
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
        [gem5_exec, icelake_config, useC3(True), "-c tests/c3_tests/hello_c3"]
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
