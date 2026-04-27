function find(array: number[], val: number) {
  if (val <= Math.min(...array)) {
    return 0;
  }

  if (val > Math.max(...array)) {
    return array.length;
  }

  const index = array.findIndex((item) => {
    return item >= val
  })

  if (index === -1) {
    return 0
  }

  return index;
}

export default find;
