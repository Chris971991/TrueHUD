// Copies embedded fonts from one SWF into another, byte for byte, under new character ids (Dovakarn's Recent Loot style,
// swf/ffdec/BUILD.md step 5).
//
//   node add-fonts.cjs <in.swf> <donor.swf> <out.swf> "<font name>" ["<font name>" ...]
//
// Each named font's DefineFont3 tag (and its DefineFontAlignZones and DefineFontName tags, when the donor has them) is
// taken from the donor, given the next free character id of <in.swf>, exported under its own name (ExportAssets, as the
// donor's shell does) and put straight after SetBackgroundColor, before anything that could use it. Nothing else in
// <in.swf> changes. A text field made by ActionScript then finds the font by name with embedFonts = true.
// Node 18 or later, no packages.
"use strict";
const fs = require("fs");
const zlib = require("zlib");

const DEFINE_FONT3 = 75, FONT_ALIGN_ZONES = 73, DEFINE_FONT_NAME = 88, EXPORT_ASSETS = 56, SET_BACKGROUND = 9;
// Tags whose body starts with the character id they define (enough to find the highest id in use)
const DEFINES = new Set([2, 6, 7, 10, 11, 12, 14, 20, 21, 22, 32, 33, 34, 35, 36, 37, 39, 46, 48, 60, 62, 75, 83, 84, 87, 90, 91]);

function readSwf(file) {
  const raw = fs.readFileSync(file);
  const sig = raw.toString("latin1", 0, 3);
  if (sig !== "FWS" && sig !== "CWS") throw new Error(`${file}: not an uncompressed or zlib SWF (${sig})`);
  const body = sig === "CWS" ? zlib.inflateSync(raw.subarray(8)) : raw.subarray(8);
  const nbits = body[0] >> 3;
  const rectBytes = Math.ceil((5 + 4 * nbits) / 8);
  const headEnd = rectBytes + 4;
  const tags = [];
  let p = headEnd;
  while (p < body.length) {
    const word = body.readUInt16LE(p);
    const code = word >> 6;
    let len = word & 0x3f;
    let hdr = 2;
    if (len === 0x3f) { len = body.readUInt32LE(p + 2); hdr = 6; }
    tags.push({ code, raw: body.subarray(p, p + hdr + len), data: body.subarray(p + hdr, p + hdr + len) });
    p += hdr + len;
    if (code === 0) break;
  }
  return { sig, version: raw[3], head: body.subarray(0, headEnd), tags };
}

function tagBytes(code, data) {
  if (data.length < 0x3f && code !== DEFINE_FONT3) {
    const h = Buffer.alloc(2);
    h.writeUInt16LE((code << 6) | data.length);
    return Buffer.concat([h, data]);
  }
  const h = Buffer.alloc(6);
  h.writeUInt16LE((code << 6) | 0x3f);
  h.writeUInt32LE(data.length, 2);
  return Buffer.concat([h, data]);
}

function withId(data, id) {
  const copy = Buffer.from(data);
  copy.writeUInt16LE(id, 0);
  return copy;
}

// DefineFont3: id u16, flags u8, language u8, name length u8, name
function fontName(data) {
  const n = data[4];
  return data.toString("utf8", 5, 5 + n).replace(/\0+$/, "");
}

function main() {
  const [inFile, donorFile, outFile, ...names] = process.argv.slice(2);
  if (!inFile || !donorFile || !outFile || names.length === 0) {
    console.error('usage: node add-fonts.cjs <in.swf> <donor.swf> <out.swf> "<font name>" ...');
    process.exit(2);
  }
  const swf = readSwf(inFile);
  const donor = readSwf(donorFile);
  let nextId = 0;
  for (const t of swf.tags) if (DEFINES.has(t.code) && t.data.length >= 2) nextId = Math.max(nextId, t.data.readUInt16LE(0));
  nextId++;
  const added = [];
  for (const name of names) {
    if (swf.tags.some((t) => t.code === DEFINE_FONT3 && fontName(t.data) === name)) throw new Error(`${inFile} already has "${name}"`);
    const font = donor.tags.find((t) => t.code === DEFINE_FONT3 && fontName(t.data) === name);
    if (!font) throw new Error(`${donorFile} has no DefineFont3 named "${name}"`);
    const oldId = font.data.readUInt16LE(0);
    const id = nextId++;
    added.push(tagBytes(DEFINE_FONT3, withId(font.data, id)));
    for (const code of [FONT_ALIGN_ZONES, DEFINE_FONT_NAME]) {
      const extra = donor.tags.find((t) => t.code === code && t.data.readUInt16LE(0) === oldId);
      if (extra) added.push(tagBytes(code, withId(extra.data, id)));
    }
    const nameBytes = Buffer.from(name + "\0", "utf8");
    const exp = Buffer.alloc(4);
    exp.writeUInt16LE(1, 0);
    exp.writeUInt16LE(id, 2);
    added.push(tagBytes(EXPORT_ASSETS, Buffer.concat([exp, nameBytes])));
    console.log(`"${name}": donor id ${oldId} -> id ${id}, ${font.data.length} bytes of outlines`);
  }
  const at = swf.tags.findIndex((t) => t.code === SET_BACKGROUND);
  const parts = [swf.head];
  swf.tags.forEach((t, i) => {
    // every tag of <in.swf> keeps its own bytes, header form included
    parts.push(t.raw);
    if (i === at) parts.push(...added);
  });
  if (at < 0) parts.splice(1, 0, ...added);
  const body = Buffer.concat(parts);
  const head = Buffer.alloc(8);
  head.write(swf.sig, 0, "latin1");
  head[3] = swf.version;
  head.writeUInt32LE(8 + body.length, 4);
  const out = Buffer.concat([head, swf.sig === "CWS" ? zlib.deflateSync(body, { level: 9 }) : body]);
  fs.writeFileSync(outFile, out);
  console.log(`${outFile}: ${out.length} bytes`);
}

main();
