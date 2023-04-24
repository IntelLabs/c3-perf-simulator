import subprocess


# Run hello world on gem5.opt using the Ice Lake config.
# If the output isn't "Hello, world!", things are broken!


gem5_dir = "../.."
gem5_exec = "build/X86/gem5.opt configs/example/se.py"
icelake_config = "--cpu-type=O3_X86_icelake_1 --caches"
safeside_dir = ""


def test_hello_icelake():
    gem5_cmd = " ".join(
        [
            gem5_exec,
            icelake_config,
            "-c tests/test-progs/hello/bin/x86/linux/hello",
        ]
    )
    gem5_output = subprocess.check_output(
        gem5_cmd, shell=True, cwd=gem5_dir
    ).decode("utf-8")
    assert "Hello world!" in gem5_output


def test_spectre_pht_icelake():
    gem5_cmd = " ".join(
        [
            gem5_exec,
            icelake_config,
            "-c tests/safeside/build/demos/spectre_v1_pht_sa",
        ]
    )
    gem5_output = subprocess.check_output(
        gem5_cmd, shell=True, cwd=gem5_dir
    ).decode("utf-8")
    assert "s3kr3t" in gem5_output
