# Authentication API

จัดการสมัครสมาชิก เข้าสู่ระบบ และสถานะการยืนยันตัวตน โดยใช้ Cookie สำหรับ Session

## Endpoints

  Method   Endpoint               หน้าที่
  -------- ---------------------- -------------------------------------
  POST     `/register`            สมัครสมาชิก
  POST     `/oauth`               Login ด้วย Email/Password
  GET      `/oauth-url/google`    ขอ Google OAuth URL
  POST     `/oauth/google-code`   Login ด้วย Google Authorization Code
  POST     `/oauth/google`        ตรวจสอบ Google Access Token
  GET      `/oauth/session`       ตรวจสอบ Session จาก Cookie
  POST     `/oauth/logout`        Logout และยกเลิก Session
  POST     `/reset-password`      ขอรีเซ็ตรหัสผ่าน
  PATCH    `/new-password`        ตั้งรหัสผ่านใหม่

## หลักการทำงาน

-   Register: ตรวจสอบข้อมูลและรหัสผ่าน จากนั้นบันทึกผู้ใช้ลง MySQL โดย Hash
    รหัสผ่านด้วย bcrypt
-   Email Login: ตรวจสอบ Email และ Password กับข้อมูลใน MySQL
-   Google Login: ตรวจสอบ Authorization Code หรือ Access Token กับ Google
-   Login สำเร็จ: Backend สร้าง Session และส่ง Session ID ผ่าน Cookie ชื่อ
    `skaai_auth`
-   Session Check: อ่าน Cookie และตรวจสอบ Session ก่อนอนุญาตให้เข้าใช้งาน
-   Logout: ยกเลิก Session ฝั่ง Backend และลบ Cookie
-   Password Reset: ตรวจสอบคำขอและ Token ก่อนเปลี่ยนรหัสผ่าน

## Request / Response

-   Request และ Response ที่ใช้ JSON ให้ใช้ Version Envelope:
    -   Request: `{"version":"1.0","data":{...}}`
    -   Success: `{"version":"1.0","data":{"success":true,...}}`
-   `/oauth-url/google` คืนค่า Google URL ตามรูปแบบที่กำหนดใน OAuth flow
-   `/register` รับข้อมูลสมัครสมาชิก
-   `/oauth` รับ `email` และ `password`
-   `/oauth/google-code` รับ `code`
-   `/oauth/google` รับ `token`
-   `/new-password` รับ Reset Token และรหัสผ่านใหม่

## Authentication & Security

-   Protected APIs ตรวจสอบ Session จาก Cookie `skaai_auth`
-   Cookie ควรตั้งค่า `HttpOnly`, `Secure` (เมื่อใช้ HTTPS), `SameSite=Lax`
    และ `Path=/`
-   Frontend ส่ง Cookie ด้วย `credentials: "include"`
-   ห้ามเก็บ Password หรือ Session ID ใน LocalStorage
-   ใช้ HTTPS, CORS allowlist และ CSRF protection สำหรับคำขอที่แก้ไขข้อมูล
-   Backend ต้องตรวจสอบสิทธิ์จาก Session ไม่เชื่อ `user_id` ที่ Frontend ส่งมา
