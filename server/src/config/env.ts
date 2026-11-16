/** Reads an environment variable in Node and in the Supabase Edge runtime (Deno). */
export function env(name: string): string | undefined {
  const deno = (globalThis as { Deno?: { env: { get(key: string): string | undefined } } }).Deno;
  if (deno) return deno.env.get(name);
  return (globalThis as { process?: { env: Record<string, string | undefined> } }).process?.env[name];
}

/**
 * True on the **test** Supabase project, whose Edge Function secrets set
 * `FINDX_FAKE_SERVICES=true` (owner decision: the test project auto-approves
 * verification and accepts test-store purchases). Never true when
 * `FINDX_ENVIRONMENT=production`, whatever the other setting says.
 */
export function fakeServicesAllowed(): boolean {
  return env('FINDX_FAKE_SERVICES') === 'true' && env('FINDX_ENVIRONMENT') !== 'production';
}
