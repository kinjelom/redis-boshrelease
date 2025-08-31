#!/bin/bash
set -uo pipefail

export PATH=$PATH:/var/vcap/packages/redis/bin

HOST="..."
PORT=6379

APP1_USER="app1"
APP1_PASS="..."

APP2_USER="app2"
APP2_PASS="..."

ADMIN_USER="admin"
ADMIN_PASS="..."

KEY1="app1:test"
KEY2="app2:test"

EXITSTATUS=0

# --- helpers ---------------------------------------------------------------

run_ok() {
  # Run a command that MUST succeed (exit code 0 with -e)
  set +e
  out="$("$@" 2>&1)"
  rc=$?
  set -e
  if [ $rc -ne 0 ]; then
    echo "FAIL: $* (rc=$rc)"
    echo "    output: $out"
    EXITSTATUS=1
  else
    echo "OK: $*"
    [ -n "$out" ] && echo "    output: $out"
  fi
}

run_fail() {
  # Run a command that MUST fail (non-zero exit with -e)
  set +e
  out="$("$@" 2>&1)"
  rc=$?
  set -e
  if [ $rc -eq 0 ]; then
    echo "FAIL (expected non-zero): $*"
    [ -n "$out" ] && echo "    output: $out"
    EXITSTATUS=1
  else
    echo "OK (failed as expected): $*"
    [ -n "$out" ] && echo "    output: $out"
  fi
}

get_val() {
  # Helper to GET value as a string (does not affect EXITSTATUS)
  set +e
  val="$(redis-cli -e -h "$HOST" -p "$PORT" --no-auth-warning --user "$1" -a "$2" get "$3" 2>/dev/null)"
  rc=$?
  set -e
  echo "$val"
  return $rc
}

assert_equals() {
  expected="$1"; actual="$2"; label="$3"
  if [[ "$actual" == "$expected" ]]; then
    echo "    assert $label: expected='$expected'"
  else
    echo "    assert $label: expected='$expected' got='$actual'"
    EXITSTATUS=1
  fi
}

# --- tests ----------------------------------------------------------------

echo -e "\n--- app1 user: allowed access to app1:*"
run_ok redis-cli -e -h "$HOST" -p "$PORT" --no-auth-warning --user "$APP1_USER" -a "$APP1_PASS" set "$KEY1" test1
val="$(get_val "$APP1_USER" "$APP1_PASS" "$KEY1")"
assert_equals "test1" "$val" "GET $KEY1 as app1"

echo -e "\n--- app1 user: forbidden access to app2:*"
run_fail redis-cli -e -h "$HOST" -p "$PORT" --no-auth-warning --user "$APP1_USER" -a "$APP1_PASS" set "$KEY2" test2
run_fail redis-cli -e -h "$HOST" -p "$PORT" --no-auth-warning --user "$APP1_USER" -a "$APP1_PASS" get "$KEY2"

echo -e "\n--- app2 user: allowed access to app2:*"
run_ok redis-cli -e -h "$HOST" -p "$PORT" --no-auth-warning --user "$APP2_USER" -a "$APP2_PASS" set "$KEY2" test3
val="$(get_val "$APP2_USER" "$APP2_PASS" "$KEY2")"
assert_equals "test3" "$val" "GET $KEY2 as app2"

echo -e "\n--- app2 user: forbidden access to app1:*"
run_fail redis-cli -e -h "$HOST" -p "$PORT" --no-auth-warning --user "$APP2_USER" -a "$APP2_PASS" set "$KEY1" test4
run_fail redis-cli -e -h "$HOST" -p "$PORT" --no-auth-warning --user "$APP2_USER" -a "$APP2_PASS" get "$KEY1"

echo -e "\n--- admin user: full access to any key"
val="$(get_val "$ADMIN_USER" "$ADMIN_PASS" "$KEY1")"; assert_equals "test1" "$val" "GET $KEY1 as admin"
val="$(get_val "$ADMIN_USER" "$ADMIN_PASS" "$KEY2")"; assert_equals "test3" "$val" "GET $KEY2 as admin"
run_ok redis-cli -e -h "$HOST" -p "$PORT" --no-auth-warning --user "$ADMIN_USER" -a "$ADMIN_PASS" set "$KEY1" test5
val="$(get_val "$ADMIN_USER" "$ADMIN_PASS" "$KEY1")"; assert_equals "test5" "$val" "GET $KEY1 as admin"
run_ok redis-cli -e -h "$HOST" -p "$PORT" --no-auth-warning --user "$ADMIN_USER" -a "$ADMIN_PASS" set "$KEY2" test6
val="$(get_val "$ADMIN_USER" "$ADMIN_PASS" "$KEY2")"; assert_equals "test6" "$val" "GET $KEY2 as admin"

echo -e "\n--- cleaning (admin)"
run_ok redis-cli -e -h "$HOST" -p "$PORT" --no-auth-warning --user "$ADMIN_USER" -a "$ADMIN_PASS" del "$KEY1"
run_ok redis-cli -e -h "$HOST" -p "$PORT" --no-auth-warning --user "$ADMIN_USER" -a "$ADMIN_PASS" del "$KEY2"

exit $EXITSTATUS

