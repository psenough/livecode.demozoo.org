import { readdir, readFile } from 'fs/promises';
import { writeFile } from 'fs/promises';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';
import { createHash } from 'crypto';

const __dirname = dirname(fileURLToPath(import.meta.url));
const DATA_DIR = join(__dirname, '../../../data');
const OUTPUT_FILE = join(__dirname, '../public/shaders.json');

function generateId(eventFile, path, index) {
  const hash = createHash('md5')
    .update(`${eventFile}-${path}-${index}`)
    .digest('hex')
    .slice(0, 8);
  return hash;
}

async function generateIndex() {
  const shaders = [];
  
  const files = await readdir(DATA_DIR);
  const jsonFiles = files.filter(f => f.endsWith('.json'));
  
  for (const file of jsonFiles) {
    try {
      const content = await readFile(join(DATA_DIR, file), 'utf-8');
      const data = JSON.parse(content);
      
      const eventName = `${data.title} - ${data.type} (${data.date})`;
      let entryIndex = 0;
      
      for (const phase of data.phases || []) {
        for (const entry of phase.entries || []) {
          if (entry.source_file && entry.source_file.endsWith('.glsl') && entry.source_file.startsWith('/shader_file_sources/')) {
            shaders.push({
              id: generateId(file, entry.source_file, entryIndex++),
              name: entry.handle?.name || 'Unknown',
              path: entry.source_file,
              event: eventName,
              image: entry.preview_image ? `/media/${entry.preview_image}` : null,
            });
          }
        }
      }
    } catch (err) {
      console.warn(`Skipping ${file}: ${err.message}`);
    }
  }
  
  await writeFile(OUTPUT_FILE, JSON.stringify(shaders, null, 2));
  console.log(`Generated index with ${shaders.length} shaders`);
}

generateIndex().catch(console.error);
