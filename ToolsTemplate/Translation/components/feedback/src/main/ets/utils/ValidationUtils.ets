import { i18n } from '@kit.LocalizationKit';

const emailRegex: RegExp = /^[^\s@]+@[^\s@]+\.[A-Za-z]{2,}$/;
const phoneNumberFormat: i18n.PhoneNumberFormat = new i18n.PhoneNumberFormat('CN', { type: 'E164' });

/**
 * 校验是否为手机号
 *
 * 在手机号自身正确的情况下支持多种风格 (非中国大陆地区必须带有国家码)
 */
export function isPhone(value: string): boolean {
  return phoneNumberFormat.isValidNumber(value);
}

/**
 * 校验是否为邮箱
 */
export function isEmail(value: string): boolean {
  return emailRegex.test(value);
}

/**
 * 校验是否为手机号或邮箱
 */
export function isPhoneOrEmail(value: string): boolean {
  return isPhone(value) || isEmail(value);
}
