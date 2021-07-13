#! /bin/sh
# file: tests/gm_tests.sh

setUp() {
  echo "setup"
}

testCase() {
  # Arrange
  # Action
  # Assert
  echo "testCase"
}

test

testEquality() {
  assertEquals 1 1
}



# Load shUnit2.
. /usr/local/bin/shunit2
