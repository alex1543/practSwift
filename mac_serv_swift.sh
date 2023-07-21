#!/usr/bin/env bash
MY_PATH="$(dirname -- "${BASH_SOURCE[0]}")"
echo "$MY_PATH"
echo "ok"
cd $MY_PATH
swift main.swift
