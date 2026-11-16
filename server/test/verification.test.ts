import { ageOn, canStartStep, INITIAL_STEPS, overallStatus, type VerificationSteps } from '../src/domain/verification';

const steps = (overrides: Partial<VerificationSteps>): VerificationSteps => ({ ...INITIAL_STEPS, ...overrides });

describe('overallStatus', () => {
  it('is approved only when phone, selfie and ID are all approved', () => {
    expect(overallStatus(steps({}), false)).toBe('pending');
    expect(overallStatus(steps({ selfie: 'approved' }), false)).toBe('pending');
    expect(overallStatus(steps({ selfie: 'approved', id: 'approved' }), false)).toBe('approved');
  });

  it('a permanent rejection overrides everything', () => {
    expect(overallStatus(steps({ selfie: 'approved', id: 'approved' }), true)).toBe('rejected');
  });

  it('a retryable rejection keeps the account pending', () => {
    expect(overallStatus(steps({ selfie: 'rejected' }), false)).toBe('pending');
  });
});

describe('canStartStep', () => {
  it('starts with the selfie and only then the ID', () => {
    expect(canStartStep(steps({}), 'selfie', false)).toBe(true);
    expect(canStartStep(steps({}), 'id', false)).toBe(false);
    expect(canStartStep(steps({ selfie: 'approved' }), 'id', false)).toBe(true);
  });

  it('never restarts an approved or in-review step', () => {
    expect(canStartStep(steps({ selfie: 'approved' }), 'selfie', false)).toBe(false);
    expect(canStartStep(steps({ selfie: 'in_review' }), 'selfie', false)).toBe(false);
  });

  it('allows a retry after a rejection, but never after a permanent one', () => {
    expect(canStartStep(steps({ selfie: 'rejected' }), 'selfie', false)).toBe(true);
    expect(canStartStep(steps({ selfie: 'rejected' }), 'selfie', true)).toBe(false);
  });

  it('needs the phone verified first', () => {
    expect(canStartStep(steps({ phone: 'not_started' }), 'selfie', false)).toBe(false);
  });
});

describe('ageOn', () => {
  it('turns 18 exactly on the birthday', () => {
    expect(ageOn('2008-11-10', new Date('2026-11-09T23:59:59Z'))).toBe(17);
    expect(ageOn('2008-11-10', new Date('2026-11-10T00:00:00Z'))).toBe(18);
  });
});
