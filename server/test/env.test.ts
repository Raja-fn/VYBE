import { fakeServicesAllowed } from '../src/config/env';

describe('test-project switches', () => {
  const saved = { ...process.env };
  afterEach(() => {
    process.env = { ...saved };
  });

  const set = (vars: Record<string, string | undefined>) => {
    for (const key of ['FINDX_FAKE_SERVICES', 'FINDX_ENVIRONMENT']) delete process.env[key];
    Object.assign(process.env, vars);
  };

  it('fakes need the explicit switch', () => {
    set({});
    expect(fakeServicesAllowed()).toBe(false);
    set({ FINDX_FAKE_SERVICES: 'true' });
    expect(fakeServicesAllowed()).toBe(true);
  });

  it('production never uses fakes', () => {
    set({ FINDX_ENVIRONMENT: 'production', FINDX_FAKE_SERVICES: 'true' });
    expect(fakeServicesAllowed()).toBe(false);
  });
});
