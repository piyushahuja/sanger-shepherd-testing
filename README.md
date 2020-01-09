# shepherd Testing

## Install

You'll need Python 3.7, or newer:

    git clone --recurse-submodules https://gitlab.internal.sanger.ac.uk/hgi/shepherd-testing.git
    python3.7 -m venv .venv
    source .venv/bin/activate
    pip install -U pip setuptools wheel -r requirements.txt

## Submit

1. Create a subdirectory in `run` named `RUN_DIR`;
2. Copy your FoFN to this directory, named `fofn` (i.e.
   `run/RUN_DIR/fofn`);
3. `./submit.sh RUN_DIR`
