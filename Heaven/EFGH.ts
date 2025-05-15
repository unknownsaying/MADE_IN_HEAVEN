
interface E {
  id: number;
  triggerEvent(): void;
}
interface F {
  data: unknown;
  serialize(): string;
}

namespace G {
  export interface MathUtils {
    add(a: number, b: number): number;
    subtract(a: number, b: number): number;
  }
  export class Calculator implements MathUtils {
    add(a: number, b: number) {
      return a + b;
    }
    subtract(a: number, b: number) {
      return a - b;
    }
  }
}
namespace H {
  export interface StringUtils {
    capitalize(str: string): string;
    reverse(str: string): string;
  }
  export const TextProcessor: StringUtils = {
    capitalize(str: string) {
      return str.charAt(0).toUpperCase() + str.slice(1);
    },
    reverse(str: string) {
      return str.split('').reverse().join('');
    }
  };
}
