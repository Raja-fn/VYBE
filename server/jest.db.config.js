/** Database tests: a throwaway local Postgres with every migration applied. */
module.exports = {
  testEnvironment: 'node',
  roots: ['<rootDir>/test/db'],
  testMatch: ['**/*.test.ts'],
  transform: { '^.+\\.tsx?$': ['ts-jest', { diagnostics: { ignoreCodes: [151001] } }] },
  globalSetup: '<rootDir>/test/db/globalSetup.ts',
  globalTeardown: '<rootDir>/test/db/globalTeardown.ts',
  testTimeout: 30000,
  // One shared database: test files take turns.
  maxWorkers: 1,
};
