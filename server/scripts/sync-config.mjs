// Copies the single AppConfig defaults file into the functions source tree.
// Deploys upload only the functions/ folder, so the file must live inside it.
import { copyFileSync, mkdirSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const here = dirname(fileURLToPath(import.meta.url));
const source = resolve(here, '../../config/app_config_defaults.json');
const target = resolve(here, '../src/config/app_config_defaults.json');
mkdirSync(dirname(target), { recursive: true });
copyFileSync(source, target);
