// @kit.NaturalLanguageKit (textProcessing, EntityType) is not supported in atomic service.
// parseAddress returns an empty ParsedAddressDTO.
import { ParsedAddressDTO } from '../models/ParsedAddressDTO';

export class TextParser {
  public static async parseAddress(_text: string): Promise<ParsedAddressDTO> {
    return new ParsedAddressDTO();
  }
}
