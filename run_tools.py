#!/usr/bin/env python

import os
import platform
import sys
import logging
import subprocess
import time
import shutil
import traceback

# ephemeral consts
logger = logging.getLogger("Nukleon_Runner")
current_platform = "windows"


def __run_cmd__(
    name: str,
    invokes: list[str],
    curr_dir: str = "",
    std_err: int = subprocess.STDOUT,
    std_out: int = subprocess.PIPE,
) -> int:
    logger.info(f'{name} @@ "{os.getcwd() + curr_dir}"')
    start_build_time: float = time.time()
    logger.info(f"{name} invoked at {time.ctime(start_build_time)}")
    build_context: subprocess.CompletedProcess[str] = subprocess.run(
        invokes,
        cwd=os.getcwd(),
        stderr=std_err,
        stdout=std_out,
        check=True,
        text=True,
    )
    # might need to finish some encoding issues with the output
    logger.info(
        f"{name} @@ TOOK: {time.time()-start_build_time} {curr_dir}\nOUTPUT [{build_context.returncode}]\n{build_context.stdout}"
    )
    return build_context.returncode


if __name__ == "__main__":
    formatter = logging.Formatter(
        "%(asctime)s | %(name)s | %(levelname)s $ %(message)s"
    )
    console_handler = logging.StreamHandler()
    console_handler.setLevel(logging.DEBUG)
    console_handler.setFormatter(formatter)
    logger.addHandler(console_handler)
    logger.setLevel(logging.DEBUG)
    wd = os.getcwd()
    os.chdir("tools/TextureMapper")
    __run_cmd__(
        "TEXTURE_COMPACT",
        curr_dir=".",
        invokes=["gradlew.bat", "run"],
    )
    os.chdir(wd)
