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
useC3 = lambda b: "-e c3_enable.env" if b else ""


"""
This file's tests are mostly sanity checks.

As part of our implementation of C3 in gem5, we had to change
several parts of the simulator which affect non-C3 execution;
however, those changes shouldn't break anything which worked
before!
"""


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
