import { OtpSendError } from '../src/services/otp/otpSender';
import { RENFLAIR_ENDPOINT, RenflairOtpSender, type FetchLike } from '../src/services/otp/renflairOtpSender';

const KEY = 'secret-key-123';

function stubFetch(status: number, body: string) {
  const urls: string[] = [];
  const fn: FetchLike = async (url) => {
    urls.push(url);
    return { ok: status >= 200 && status < 300, status, text: async () => body };
  };
  return { fn, urls };
}

describe('Renflair OTP sender', () => {
  it('calls V1.php with the key, the 10-digit number and the code', async () => {
    const { fn, urls } = stubFetch(200, '{"status":"SUCCESS","message":"OTP sent"}');
    await new RenflairOtpSender(KEY, fn).send('+919876543210', '0427');
    const url = new URL(urls[0]);
    expect(`${url.origin}${url.pathname}`).toBe(RENFLAIR_ENDPOINT);
    expect(Object.fromEntries(url.searchParams)).toEqual({ API: KEY, PHONE: '9876543210', OTP: '0427' });
  });

  it.each(['success', 'Success', 'true', '1', 'ok'])('accepts status %s', async (status) => {
    const { fn } = stubFetch(200, JSON.stringify({ status, message: 'x' }));
    await expect(new RenflairOtpSender(KEY, fn).send('+919876543210', '1234')).resolves.toBeUndefined();
  });

  it('reports a refusal with Renflair message, never the key', async () => {
    const { fn } = stubFetch(200, '{"status":"FAILED","message":"Insufficient balance"}');
    const error = await new RenflairOtpSender(KEY, fn).send('+919876543210', '1234').catch((e: unknown) => e);
    expect(error).toBeInstanceOf(OtpSendError);
    expect((error as Error).message).toContain('Insufficient balance');
    expect((error as Error).message).not.toContain(KEY);
  });

  it('treats HTTP errors, non-JSON answers and network failures as not sent', async () => {
    await expect(new RenflairOtpSender(KEY, stubFetch(500, 'oops').fn).send('+919876543210', '1234')).rejects.toBeInstanceOf(OtpSendError);
    await expect(new RenflairOtpSender(KEY, stubFetch(200, '<html>').fn).send('+919876543210', '1234')).rejects.toBeInstanceOf(OtpSendError);
    const offline: FetchLike = () => Promise.reject(new TypeError(`fetch failed for ${KEY}`));
    const error = await new RenflairOtpSender(KEY, offline).send('+919876543210', '1234').catch((e: unknown) => e);
    expect(error).toBeInstanceOf(OtpSendError);
    expect((error as Error).message).not.toContain(KEY);
  });

  it('needs a key and an Indian number', async () => {
    expect(() => new RenflairOtpSender('')).toThrow(OtpSendError);
    await expect(new RenflairOtpSender(KEY, stubFetch(200, '{}').fn).send('+14155550100', '1234')).rejects.toBeInstanceOf(OtpSendError);
  });
});
