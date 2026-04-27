export class TSExtension {
  static addProperty(target: any, key: string, value: any) : any {
    if (!target[key]) {
      target[key] = value;
    }
    return target;
  }

  static addProperties(target: any, properties:any) : any {
    for (const key in properties) {
      if (!target[key]) {
        target[key] = properties[key];
      }
    }
    return target;
  }
}

