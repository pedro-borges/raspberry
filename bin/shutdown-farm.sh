#!/usr/bin/env bash

ssh pi@alpha.local "sudo shutdown $*"
ssh pi@beta.local "sudo shutdown $*"
ssh pi@gamma.local "sudo shutdown $*"
ssh pi@delta.local "sudo shutdown $*"