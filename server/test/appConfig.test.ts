import { defaultAppConfig, mergeOverrides } from '../src/config/appConfig';

describe('AppConfig defaults', () => {
  it('holds the agreed business numbers', () => {
    expect(defaultAppConfig.discoveryRadiusKm).toBe(5);
    expect(defaultAppConfig.signupBonusCredits).toBe(20);
    expect(defaultAppConfig.creditCostStartChat).toBe(1);
    expect(defaultAppConfig.creditCostBookSpot).toBe(0);
    expect(defaultAppConfig.creditCostInstantRequest).toBe(0);
    expect(defaultAppConfig.plans.map((p) => [p.tier, p.monthlyCredits])).toEqual([
      ['free', 0],
      ['plus', 100],
      ['premium', 300],
    ]);
    expect(defaultAppConfig.topUpPacks.map((p) => p.credits)).toEqual([10, 30, 75]);
    expect(defaultAppConfig.launchCity.name).toBe('Mumbai');
  });
});

describe('app_config overrides', () => {
  it('applies a valid override', () => {
    expect(mergeOverrides({ creditCostBookSpot: 6 }).creditCostBookSpot).toBe(6);
  });

  it('ignores an invalid override and keeps every default', () => {
    expect(mergeOverrides({ creditCostBookSpot: -1 })).toEqual(defaultAppConfig);
  });
});
