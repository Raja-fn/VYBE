import type postgres from 'postgres';

/** A connection pool or an open transaction. */
export type Sql = postgres.Sql | postgres.TransactionSql;
export type Db = postgres.Sql;

/** Postgres numeric/bigint come back as strings; this reads them as numbers. */
export const num = (value: unknown): number => (value === null || value === undefined ? 0 : Number(value));

/** Plain data for a jsonb column (typed interfaces lack the index signature postgres.js wants). */
export const asJson = (value: object): postgres.JSONValue => value as unknown as postgres.JSONValue;
