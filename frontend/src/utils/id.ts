import { Long } from "@/api/pb/user";

export function idToString(id?: Long) {
  if (!id) {
    return "!";
  }
  let out = id.low.toString(32).padStart(7, "0");
  if (id.high) {
    out += "-";
    out += id.high.toString(32).padStart(7, "0");
  }
  return out;
}

export function stringToId(str: string): Long {
  const [lowStr, highStr] = str.split("-");
  const high = parseInt(highStr ?? "0", 32);
  const low = parseInt(lowStr ?? "0", 32);
  return {
    high,
    low,
    unsigned: false,
  };
}
