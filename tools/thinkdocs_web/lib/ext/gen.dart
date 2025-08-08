R catchOf<R, E>({
    required R Function()　tryDo,
    required R Function(E) catchDo,
    void Function()? finallyDo
  }){
  late R ret;
  try {
    ret = tryDo();
  } on E catch (E e) {
    ret = catchDo(e);
  } finally {
    if (finallyDo != null) {
      finallyDo();
    }
  }
  return ret;
}