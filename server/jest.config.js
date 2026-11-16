/** Unit tests: no database needed. */
module.exports = {
  testEnvironment: 'node',
  roots: ['<rootDir>/test'],
  testPathIgnorePatterns: ['/test/db/'],
  transform: { '^.+\\.tsx?$': ['ts-jest', { diagnostics: { ignoreCodes: [151001] } }] },
};
