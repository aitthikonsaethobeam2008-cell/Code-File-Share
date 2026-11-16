# Code & File Share

เว็บแชร์โค้ด ไฟล์ และข้อความในห้องร่วมกัน พัฒนาด้วย Node.js, Express และ SQLite โดยคงหน้าเว็บและฟีเจอร์เดิมไว้

## ต้องใช้
- Node.js **22.13 ขึ้นไป** (ใช้ `node:sqlite` ที่มากับ Node.js)
- npm

## เปิดใช้งานบนเครื่อง
```bash
npm install
npm start
```
เปิด `http://localhost:3000` หรือใช้พอร์ตจากตัวแปร `PORT`

## Deploy บน Render
สร้างบริการชนิด **Web Service** แล้วตั้งค่า:

| รายการ | ค่า |
|---|---|
| Runtime | Node |
| Build Command | `npm install` |
| Start Command | `node index.js` |
| Health Check Path | `/health` |

แอป bind ที่ `0.0.0.0` และใช้ `process.env.PORT` ตามที่ Render กำหนด

### เก็บฐานข้อมูลและไฟล์อัปโหลดให้คงอยู่
Render filesystem ปกติเป็น ephemeral; หากต้องการเก็บ SQLite และไฟล์ที่อัปโหลดข้าม deploy/restart ให้เพิ่ม Persistent Disk (เช่น mount path `/var/data`) แล้วตั้ง Environment Variables:

```text
DATA_DIR=/var/data/data
UPLOAD_DIR=/var/data/uploads
```

Persistent Disk ใช้ได้กับบริการแบบชำระเงินตามข้อกำหนดของ Render และข้อมูลเดิมจากโฟลเดอร์ `data/` กับ `uploads/` ใน ZIP ต้องย้ายไปยังโฟลเดอร์บน disk ที่กำหนดก่อนเปิดใช้งานจริง **อย่าลบหรือเขียนทับฐานข้อมูลเดิมก่อนสำรองข้อมูล**

หากไม่ตั้ง Persistent Disk ข้อมูลใหม่ที่เขียนใน `data/` และ `uploads/` อาจหายเมื่อมีการ deploy หรือ restart

## Environment Variables

| ตัวแปร | ค่าเริ่มต้น | ความหมาย |
|---|---:|---|
| `PORT` | `3000` | พอร์ต HTTP (Render กำหนดให้อัตโนมัติ) |
| `MAX_FILE_MB` | `100` | ขนาดไฟล์สูงสุดต่อไฟล์ (MB) |
| `MAX_FILES` | `20` | จำนวนไฟล์สูงสุดต่อการอัปโหลด |
| `MAX_CODE_KB` | `500` | ขนาด JSON/โค้ดสูงสุดโดยประมาณ (KB) |
| `EXTRA_BLOCKED_EXT` | ว่าง | นามสกุลเพิ่มเติมที่ไม่อนุญาต คั่นด้วย comma |
| `DATA_DIR` | `./data` | โฟลเดอร์ฐานข้อมูล SQLite |
| `UPLOAD_DIR` | `./uploads` | โฟลเดอร์เก็บไฟล์ |

คัดลอก `.env.example` เป็น `.env` สำหรับพัฒนาในเครื่อง ห้าม commit `.env`

## โครงสร้าง
```text
index.js                 จุดเริ่มต้นสำหรับ Render
server/index.js           Express routes, API, uploads, downloads
server/config.js          Environment/configuration
server/db.js              SQLite initialization and queries
public/index.html         หน้าเว็บ
public/css/style.css      สไตล์เดิม
public/js/app.js          Frontend logic
public/img/               รูปภาพของเว็บไซต์
data/share.db             SQLite database (ไม่ควร commit)
uploads/                  ไฟล์อัปโหลด (ไม่ควร commit)
```

## Routes สำคัญ
- Pages: `/`, `/new/code`, `/new/file`, `/share/:id`, `/file/:id`, `/room/:code`
- Code: `POST /api/code`, `GET|PUT /api/code/:id`
- Files: `POST /api/file`, `GET /api/file/:id`, `GET /api/file/:id/download/:fid`
- Chat: `/api/rooms/:code/messages` และ `/api/rooms/:code/download/:id`
- Health: `GET /health`

## หมายเหตุ
- ลิงก์แชร์เป็นแบบผู้ที่มีลิงก์เข้าถึงได้; ห้องโค้ดเดิมอนุญาตให้แก้ไขเนื้อหาได้
- ระบบบล็อกนามสกุลไฟล์ที่มีความเสี่ยงบางประเภท และสร้างชื่อไฟล์บนดิสก์แบบสุ่ม
- ไฟล์ที่อัปโหลดจะถูกดาวน์โหลดเป็น attachment พร้อม `X-Content-Type-Options: nosniff`
- Google Fonts และ Highlight.js ยังโหลดจาก CDN เหมือนเดิม
