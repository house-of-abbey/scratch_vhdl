export function isObject(item: unknown): item is Record<string, unknown> {
  return Boolean(item) && typeof item === 'object' && !Array.isArray(item);
}

export function mergeDeep<
  T extends Record<string, unknown> = Record<string, unknown>
>(target: T, source: T): T {
  if (isObject(target) && isObject(source)) {
    for (const key in source) {
      let t = target[key];
      const s = source[key];
      if (isObject(s)) {
        if (!t) {
          Object.assign(target, { [key]: {} });
          t = target[key];
        }
        if (isObject(t)) mergeDeep(t, s);
      } else Object.assign(target, { [key]: s });
    }
  }

  return target;
}
