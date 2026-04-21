export function codeStatusChecker(status?: number): boolean {
  if (status) {
    return status >= 200 && status < 300;
  } else {
    return false;
  }
}
