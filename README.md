# shepherd Testing

## Install

You'll need Python 3.7, or newer:

    git clone --recurse-submodules https://gitlab.internal.sanger.ac.uk/hgi/shepherd-testing.git
    python3.7 -m venv .venv
    source .venv/bin/activate
    pip install -U pip setuptools wheel -r requirements.txt

## Submit

1. Create a subdirectory in `run`, say named `RUN_DIR`;
2. Copy your FoFN, which must be named `fofn`, to this directory (i.e.,
   `run/RUN_DIR/fofn`);
3. `./submit.sh RUN_DIR`.

This will transfer the files listed in your FoFN to iRODS, in
`/humgen/shepherd_testing/RUN_DIR`, with common prefixes stripped. All
logs will be written to `run/RUN_DIR`.

**NOTE** Your FoFN must be newline-delimited absolute paths.
