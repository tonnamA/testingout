# SKAAI Authentication Reproduction Blueprint & Specification

> **คำแนะนำสำหรับ AI Agent / Developer:**
> เอกสารฉบับนี้กำหนดระบบ Authentication ของ SKAAI โดยคงรูปแบบ Payload, ลำดับการตรวจสอบ, อัลกอริทึมการ Hash, โครงสร้าง Database Schema และ Client Router Interceptor ตามข้อกำหนดเดิม
>
> **การปรับปรุงฉบับนี้:** เปลี่ยนจากการเก็บ Email/Password ไว้ใน `localStorage` เป็นการใช้ **HttpOnly Authentication Cookie** โดย Backend จะตรวจสอบ Credentials เพียงตอน Login แล้วออก Cookie สำหรับยืนยันตัวตนในคำขอถัดไป จะไม่เก็บหรือส่ง Password กลับไปยัง Browser เพื่อใช้เป็นสถานะ Login

---

## 1. ข้อมูลระดับสถาปัตยกรรม (Architecture Overview)

ระบบ Authentication ของ SKAAI รองรับ 2 วิธีหลัก:

1. **Google OAuth 2.0 (Primary):** ตรวจสอบผ่าน Google Access Token / Authorization Code
2. **Email & Password (Secondary):** ตรวจสอบกับฐานข้อมูล MySQL โดยใช้ `bcrypt`
3. **Cookie-based Authentication State:** หลังตรวจสอบตัวตนสำเร็จ Backend จะออก Authentication Cookie ที่มีคุณสมบัติ `HttpOnly` เพื่อให้ Browser ส่ง Cookie กลับไปกับ Request โดยอัตโนมัติ
4. **Client-side Role Guard:** Frontend เรียก API ตรวจสอบสถานะ Authentication เพื่อรับข้อมูล User และ Role ทุกครั้งที่ Application โหลดหรือเปลี่ยนหน้า

> หมายเหตุ: Cookie จะเก็บ Session Identifier หรือค่ารับรองที่ Backend ตรวจสอบได้ ไม่เก็บ Email/Password แบบ Plaintext การใช้ Cookie ไม่ได้หมายความว่าควรนำ Password ไปใส่ใน Cookie โดยตรง

---

## 2. ฐานข้อมูลที่ต้องเตรียม (Database Schema)

ตาราง `user` ใน MySQL Database:

```sql
CREATE TABLE `user` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(255) NOT NULL,
  `email` VARCHAR(255) UNIQUE NOT NULL,
  `password` VARCHAR(255) NOT NULL,
  `role` INT NOT NULL DEFAULT 1
);
```

- บัญชีที่สมัครด้วย Email/Password จะเก็บ Password ที่ผ่าน bcrypt hashing
- บัญชีที่สมัครด้วย Google ให้ใช้วิธีระบุบัญชี Google แยกอย่างชัดเจน เช่น `auth_provider` หรือ nullable password ตามการออกแบบ Database
- ไม่ควรเก็บข้อความ `'google'` เป็น Password จริง เพราะอาจทำให้การตรวจสอบ Password สับสน

> หากต้องคง Database Schema เดิมแบบ 1:1 ให้ใช้ค่า `'google'` ตามระบบเดิมได้ แต่ควรตรวจสอบ `password != 'google'` ก่อนเรียก `bcrypt.checkpw()` ทั้งนี้ข้อเสนอเรื่อง `auth_provider` เป็นข้อเสนอด้านความปลอดภัย ไม่ใช่ส่วนหนึ่งของ Schema เดิม

---

## 3. รูปแบบ Envelope Payload ของ API (Version Handshake Protocol)

ทุก Request และ Response ที่สื่อสารระหว่าง Frontend ↔ Backend ใช้ Version Envelope ตามรูปแบบต่อไปนี้

### Request Envelope

```json
{
  "version": "1.0",
  "data": { }
}
```

### Response Envelope เมื่อสำเร็จ

```json
{
  "version": "1.0",
  "data": {
    "success": true
  }
}
```

### Response Envelope เมื่อ Version ไม่ตรงกัน

HTTP Status `426 Upgrade Required`

```json
{
  "version": "1.0",
  "data": {
    "success": false
  },
  "text": "Version Not Match"
}
```

> ข้อยกเว้นที่ต้องยืนยัน: Specification เดิมระบุ Response ของ `GET /oauth-url/google` เป็น `{ "url": "..." }` โดยไม่ได้ห่อ Version Envelope หากต้องการใช้ Envelope กับทุก Endpoint ให้ปรับ Response ของ Endpoint นี้ให้เป็นรูปแบบเดียวกัน

---

## 4. Client State และ Authentication Cookie

### 4.1 Cookie ที่ Backend ออกให้

หลัง Login สำเร็จ Backend จะส่ง `Set-Cookie` กลับไปยัง Browser เช่น:

> ตัวอย่าง Header ที่ถูกต้อง:

```http
Set-Cookie: skaai_auth=<opaque-session-value>; HttpOnly; Secure; SameSite=Lax; Path=/; Max-Age=86400
```

คุณสมบัติที่กำหนด:

- `HttpOnly`: JavaScript อ่าน Cookie ไม่ได้ ลดความเสี่ยงจากการขโมย Cookie ผ่าน JavaScript
- `Secure`: ส่ง Cookie ผ่าน HTTPS เท่านั้น (Production)
- `SameSite=Lax`: ลดความเสี่ยง CSRF ในกรณีทั่วไป และรองรับ OAuth Redirect แบบ Top-level Navigation
- `Path=/`: ใช้ Cookie กับทุก API Path ของเว็บไซต์
- `Max-Age`: กำหนดอายุ Cookie ให้สอดคล้องกับอายุ Session ฝั่ง Backend
- `Domain`: ไม่กำหนด เว้นแต่จำเป็นต้องแชร์ Cookie ระหว่าง Subdomain

Backend ต้องตรวจสอบ Cookie และ Session/Token ที่ผูกกับ Cookie ทุกครั้งที่เรียก API ที่ต้องยืนยันตัวตน และต้องสามารถยกเลิก Session ได้เมื่อหมดอายุหรือถูกเพิกถอน

### 4.2 LocalStorage

Email และ Password จะไม่ถูกเก็บใน `localStorage` อีกต่อไป

ยังคงใช้ LocalStorage สำหรับ Google OAuth ตาม Flow เดิมได้:

```javascript
const SETTING = {
  LocalStorage: {
    Login: {
      code: "signin-code",
      token: "signin-token"
    }
  }
};
```

- `signin-code`: Temporary Google OAuth Authorization Code ใช้ระหว่าง Callback เท่านั้น และลบทิ้งหลังแลกเปลี่ยนสำเร็จ/ล้มเหลว
- `signin-token`: Google Access Token ตาม Flow เดิม
- **ไม่มี** `signin-email` และ `signin-password`

> ข้อเสนอด้านความปลอดภัย: Access Token ของ Google ก็ควรหลีกเลี่ยงการเก็บใน LocalStorage หากสามารถปรับให้ Backend จัดการ OAuth และออก HttpOnly Cookie ได้ แต่การปรับดังกล่าวเป็นการเปลี่ยนแปลงเพิ่มเติมจากขอบเขตการย้าย Email/Password ในฉบับนี้

---

## 5. กระบวนการตรวจสอบสิทธิ์ฝั่ง Client (Frontend Authentication Flow)

เมื่อ Application เริ่มต้นหรือเปลี่ยนหน้า Frontend เรียก API ตรวจสอบสถานะ Authentication โดยใช้ Cookie ที่ Browser แนบให้โดยอัตโนมัติ

### 5.1 ตรวจสอบ Authentication Cookie

เพิ่ม Endpoint:

`GET /oauth/session`

Backend อ่าน Cookie `skaai_auth` ตรวจสอบ Session และส่ง Profile กลับ:

```json
{
  "version": "1.0",
  "data": {
    "success": true,
    "id": 1,
    "name": "Somchai",
    "role": 1
  }
}
```

หาก Cookie ไม่มี หมดอายุ หรือไม่ถูกต้อง:

```json
{
  "version": "1.0",
  "data": {
    "success": false
  }
}
```

Frontend เรียกด้วย `credentials: "include"`:

```javascript
const getSessionInfo = async () => {
  return fetch(SETTING.Server + "/oauth/session", {
    method: "GET",
    credentials: "include"
  })
    .then(res => res.json())
    .then(info => info.data.success ? info.data : { success: false })
    .catch(() => ({ success: false }));
};
```

### 5.2 Google OAuth Fallback

คงลำดับ Google Access Token → Google Auth Code ตามเดิม:

```javascript
const Security = {
  OAuth: {
    getRole: async () => {
      const info = await Security.OAuth.getInfo();
      if (!info.success) return RoleList.unknown;
      return Object.values(RoleList)[info.role];
    },

    getInfo: async () => {
      // Step A: ตรวจสอบ Google Access Token
      const token = window.localStorage.getItem("signin-token");
      if (token) {
        return fetch(SETTING.Server + "/oauth/google", {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          credentials: "include",
          body: JSON.stringify({
            version: "1.0",
            data: { token: token }
          })
        })
          .then(res => res.json())
          .then(info => info.data.success ? info.data : { success: false })
          .catch(() => {
            window.localStorage.removeItem("signin-token");
            return { success: false };
          });
      }

      // Step B: ตรวจสอบ Google Auth Code จาก Redirect Callback
      const code = window.localStorage.getItem("signin-code");
      if (code) {
        return fetch(SETTING.Server + "/oauth/google-code", {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          credentials: "include",
          body: JSON.stringify({
            version: "1.0",
            data: { code: code }
          })
        })
          .then(res => res.json())
          .then(info => info.data.success ? info.data : { success: false })
          .catch(() => {
            window.localStorage.removeItem("signin-code");
            return { success: false };
          });
      }

      // Step C: ตรวจสอบ Authentication Cookie
      return getSessionInfo();
    }
  }
};
```

> การเรียงลำดับข้างต้นคง Google Token และ Code ก่อน แล้วใช้ Cookie ตรวจสอบสถานะ Email/Password เป็นลำดับสุดท้าย ทั้งนี้เมื่อ Google Login สำเร็จ Backend ควรออก Authentication Cookie ด้วย เพื่อให้ API ภายในระบบใช้กลไกตรวจสอบสิทธิ์เดียวกันได้

---

## 6. ข้อกำหนด API Backend (FastAPI Endpoint Specs)

### 6.1 `POST /oauth` (Email & Password Login)

**Request Body:**

```json
{
  "version": "1.0",
  "data": {
    "email": "user@example.com",
    "password": "UserPass123!"
  }
}
```

**Backend Logic:**

1. ตรวจสอบ Version Envelope
2. ค้นหาแถวในตาราง `user` ด้วย `email`
3. หากไม่พบ ให้คืน `success: false`
4. ตรวจสอบ Password ด้วย `bcrypt.checkpw(password, db_hashed_password)`
5. หากถูกต้อง สร้าง Session/ค่ารับรองแบบสุ่มที่ปลอดภัย และเก็บ Session ฝั่ง Backend
6. ส่ง `Set-Cookie` สำหรับ `skaai_auth` โดยตั้ง `HttpOnly`, `Secure` (Production), `SameSite=Lax`, `Path=/` และอายุที่กำหนด
7. คืนค่า Profile โดยไม่ส่ง Password หรือ Session Secret ใน JSON

**Response:**

```json
{
  "version": "1.0",
  "data": {
    "success": true,
    "id": 1,
    "name": "Somchai",
    "role": 1
  }
}
```

หาก Login ไม่สำเร็จ:

```json
{
  "version": "1.0",
  "data": {
    "success": false
  }
}
```

### 6.2 `GET /oauth/session` (ตรวจสอบ Authentication Cookie)

**Backend Logic:**

1. อ่าน Cookie `skaai_auth`
2. ตรวจสอบ Session/ค่ารับรองกับ Backend
3. ตรวจสอบวันหมดอายุและสถานะการเพิกถอน
4. ค้นหา User ที่ผูกกับ Session
5. คืน `id`, `name`, `role` หากถูกต้อง
6. หากไม่ถูกต้อง ให้คืน `success: false` และล้าง Cookie ที่หมดอายุ/ไม่ถูกต้อง

### 6.3 `GET /oauth-url/google` (ขอ Redirect URL เข้าสู่ระบบ Google)

คง Endpoint และ Google Authorization URL ตาม Specification เดิม:

```json
{
  "url": "https://accounts.google.com/o/oauth2/v2/auth?response_type=code&client_id={CLIENT_ID}&redirect_uri={REDIRECT_URI}&scope=https://www.googleapis.com/auth/userinfo.profile https://www.googleapis.com/auth/userinfo.email&prompt=select_account"
}
```

### 6.4 `POST /oauth/google-code` (แลกเปลี่ยน Auth Code เป็น Token และ Profile)

**Request Body:**

```json
{
  "version": "1.0",
  "data": {
    "code": "4/0A..."
  }
}
```

**Backend Logic:**

1. แลกเปลี่ยน Code กับ Google Token Endpoint
2. ใช้ Access Token ขอ Google User Profile
3. ค้นหา User ด้วย Email
4. หากเป็น User ใหม่ ให้สร้างบัญชีตามกฎ Google Account
5. สร้าง Authentication Session ฝั่ง Backend
6. ส่ง `Set-Cookie` สำหรับ `skaai_auth`
7. คืน Profile Data โดยไม่จำเป็นต้องส่ง Access Token กลับ Frontend หากระบบใช้ Cookie เป็นกลไกหลัก

> หากต้องคงการส่ง Google Access Token กลับและเก็บ `signin-token` ตามระบบเดิม ให้ทำได้ตาม Compatibility Mode แต่ไม่ควรใช้ Token ใน LocalStorage เป็นกลไกหลักของ API ภายในระบบ

### 6.5 `POST /oauth/google` (ตรวจสอบ Google Access Token)

**Request Body:**

```json
{
  "version": "1.0",
  "data": {
    "token": "ya29.a0..."
  }
}
```

**Backend Logic:**

1. ตรวจสอบ Token กับ Google UserInfo Endpoint
2. หาก Google ตอบ Error ให้ปฏิเสธคำขอ
3. ค้นหา User ด้วย Email
4. หากพบ User ให้สร้าง/ยืนยัน Authentication Session ฝั่ง Backend
5. ส่ง `Set-Cookie` สำหรับ `skaai_auth`
6. คืน Profile Data

### 6.6 `POST /register` (ลงทะเบียนผู้ใช้งาน)

**Password Validation Rules:**

- ความยาวอย่างน้อย 8 ตัวอักษร
- มีอักษรตัวพิมพ์เล็ก `[a-z]` อย่างน้อย 1 ตัว
- มีอักษรตัวพิมพ์ใหญ่ `[A-Z]` อย่างน้อย 1 ตัว
- มีตัวเลข `[0-9]` อย่างน้อย 1 ตัว
- มีสัญลักษณ์พิเศษ `[!@#$%^&*()_+.?]` อย่างน้อย 1 ตัว
- ไม่มีช่องว่าง `\s`

**Hashing Algorithm:**

```python
salt = bcrypt.gensalt(rounds=12)
hashed = bcrypt.hashpw(password.encode("utf-8"), salt).decode("utf-8")
```

### 6.7 `POST /reset-password` และ `PATCH /new-password` (ระบบรีเซ็ตรหัสผ่าน)

คง Endpoint และรูปแบบ Reset Token ตาม Specification เดิม:

1. ใช้ Timestamp ปัจจุบัน
2. ใช้ข้อมูล Password Hash เดิมเป็นส่วนหนึ่งของ Key Derivation ตามระบบเดิม
3. ตรวจสอบ Token และอายุไม่เกิน 300 วินาที (5 นาที)
4. เมื่อเปลี่ยน Password สำเร็จ ให้ยกเลิก Authentication Session เดิมทั้งหมด และให้ผู้ใช้ Login ใหม่

> หมายเหตุด้านความปลอดภัย: การออกแบบ Custom AES-CBC Token ที่ไม่มีการระบุ Integrity Protection อย่างชัดเจนไม่ควรนำไปใช้จริงโดยไม่ทบทวน ควรพิจารณา Token แบบสุ่มที่เก็บ Hash ฝั่ง Server หรือ Signed Token ที่มีการตรวจสอบ Integrity

### 6.8 `POST /oauth/logout` (ออกจากระบบ)

เพิ่ม Endpoint สำหรับเพิกถอน Session ฝั่ง Backend:

1. อ่าน Authentication Cookie
2. เพิกถอน Session ที่เกี่ยวข้อง
3. ส่ง `Set-Cookie` เพื่อลบ `skaai_auth` โดยใช้ `Path=/` และ Cookie Attributes ให้ตรงกับตอนสร้าง

Response:

```json
{
  "version": "1.0",
  "data": {
    "success": true
  }
}
```

Frontend ต้องเรียก Logout API ก่อนเปลี่ยนกลับหน้าแรก ไม่ใช่ลบเฉพาะ LocalStorage

---

## 7. กลไกฝั่ง Client-side UI & Routing Integration

### 7.1 Flow การ Login ด้วย Email/Password

1. User กรอก Email และ Password
2. Frontend ส่ง `POST /oauth`
3. Backend ตรวจสอบ Credentials
4. เมื่อสำเร็จ Backend ส่ง `Set-Cookie` แบบ HttpOnly
5. Browser เก็บ Cookie โดยอัตโนมัติ
6. Frontend เก็บเฉพาะ Profile ที่จำเป็นใน Memory/State ของ Application ได้ แต่ไม่เก็บ Password ใน LocalStorage
7. Frontend เปลี่ยนหน้าไปยังหน้าสมาชิก

ตัวอย่าง Fetch:

```javascript
const response = await fetch(SETTING.Server + "/oauth", {
  method: "POST",
  headers: { "Content-Type": "application/json" },
  credentials: "include",
  body: JSON.stringify({
    version: "1.0",
    data: {
      email: email.value,
      password: password.value
    }
  })
});
```

### 7.2 Flow การ Login ด้วย Google (`google-oauth.html`)

1. Google Redirect กลับมาที่ `/google-oauth?code=XXXX`
2. Frontend ส่ง Code ไป `POST /oauth/google-code`
3. Backend แลก Code และตรวจสอบ Profile กับ Google
4. Backend สร้าง Authentication Session และส่ง HttpOnly Cookie
5. Frontend ลบ Temporary Code หลังใช้งาน
6. Redirect ไปยังหน้าสมาชิก

### 7.3 Flow การ Logout (`logout.html`)

Frontend เรียก `POST /oauth/logout` ด้วย `credentials: "include"` เพื่อให้ Backend เพิกถอน Session และลบ Cookie จากนั้น Redirect กลับหน้าแรก

### 7.4 Role Guard ใน Router (`index_main.js`)

เมื่อ `Route.goto(path)` ทำงาน:

1. เรียก `Security.OAuth.getInfo()`
2. รับ Role จาก Backend ผ่าน Cookie-authenticated request
3. Map Role เป็น `unknown`, `general`, หรือ `admin`
4. ตรวจสอบ `RouteList[role][page]`
5. หากไม่มี Route สำหรับ Role นั้น ให้แสดง 404 หรือ Redirect ตามกฎของระบบ

> Role Guard ฝั่ง Frontend ใช้ควบคุมการแสดงหน้าเท่านั้น Backend ต้องตรวจสอบ Authentication และ Authorization ทุก Endpoint ที่เข้าถึงข้อมูลหรือดำเนินการสำคัญ ห้ามเชื่อถือ Role ที่ Frontend ส่งมาเอง

---

## 8. ข้อกำหนดเพิ่มเติมด้าน Cookie, CORS และ CSRF

- ใช้ HTTPS ใน Production และเปิด `Secure` ให้ Cookie
- ใช้ `HttpOnly` เพื่อป้องกัน JavaScript อ่าน Authentication Cookie
- ใช้ `SameSite=Lax` หรือค่าที่เหมาะกับ Domain และ OAuth Flow
- หาก Frontend และ Backend อยู่คนละ Origin ให้กำหนด CORS แบบระบุ Origin ที่อนุญาต ห้ามใช้ `*` ร่วมกับ Credential
- Frontend ต้องใช้ `credentials: "include"` ใน Fetch ที่ต้องส่ง Cookie
- หากใช้ Cookie Authentication ต้องออกแบบ CSRF Protection สำหรับ Request ที่เปลี่ยนแปลงข้อมูล เช่น POST, PATCH และ DELETE โดยใช้ CSRF Token หรือแนวทางที่เหมาะสมร่วมกับ SameSite
- อย่าบันทึก Password, Session Secret หรือ Access Token ลง Log
- กำหนดอายุ Session, การเพิกถอน Session และการหมุน Session ID หลัง Login ให้ชัดเจน

---

## 9. Checklist สรุปสำหรับการ Implement

- [ ] คง Endpoint เดิม: `/oauth`, `/oauth-url/google`, `/oauth/google-code`, `/oauth/google`, `/register`, `/reset-password`, `/new-password`
- [ ] เพิ่ม `GET /oauth/session` สำหรับตรวจสอบ Authentication Cookie
- [ ] เพิ่ม `POST /oauth/logout` สำหรับเพิกถอน Session และลบ Cookie
- [ ] ลบการใช้ `signin-email` และ `signin-password` จาก LocalStorage
- [ ] Backend ออก `skaai_auth` Cookie หลัง Login สำเร็จ
- [ ] Cookie ต้องเป็น HttpOnly, Secure ใน Production, SameSite และ Path ตามที่กำหนด
- [ ] Frontend ใช้ `credentials: "include"` ใน Request ที่ต้องส่ง Cookie
- [ ] คง Google `signin-code` และ `signin-token` ตาม Compatibility Mode หากยังต้องใช้ Flow เดิม
- [ ] ใช้ bcrypt rounds 12 สำหรับ Password Hashing
- [ ] ตรวจสอบ Version Envelope ตาม `version: "1.0"`
- [ ] ตรวจสอบ Authentication และ Authorization ที่ Backend ทุก Protected Endpoint
- [ ] ตั้งค่า CORS และ CSRF Protection ให้สอดคล้องกับ Cookie Authentication
- [ ] ทดสอบ Login, Refresh Page, Role Guard, Logout, Cookie Expiry และ Password Reset
