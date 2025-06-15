import { BigNumber } from "ethers";

export function paramParseBoolean(param: string): boolean {
   switch (param){
        case "true":
        case "1":
        case "on":
        case "yes":
            return true;
        case "false":
        case "0":
        case "off":
        case "no":
            return false;
        default:
            throw Error(`Invalid parameter value: ${param}`);
    }
}

export function paramParseBigNumberList(param: string): BigNumber[] {
    return splitString(param).map(BigNumber.from);
}

export function splitString(s: string) : string[] {
    return s.indexOf(" ") != -1 ? s.split(" ") : s.split(",");
}
