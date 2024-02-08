# HARDEN project
# Implementation of Intel's C3 (MICRO '21) ISA extension
# Authors: Joey Rudek

microcode = """
def macroop CCENCPTR_R_R
{
    ccencptr reg, reg, regm
};

def macroop CCDECPTR_R_R
{
    ccdecptr reg, reg, regm
};

def macroop FCNT_R_R
{
		.function_count

    fcnt reg, reg, regm
};
"""
