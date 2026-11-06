# Authentication Management (Auth)

## 1. Input (ข้อมูลนำเข้า)
- อีเมล (Email)
- รหัสผ่าน (Password) สำหรับสมัครสมาชิกและเข้าสู่ระบบ
- Google OAuth Token สำหรับเข้าสู่ระบบผ่าน Google
- Session ID / Cookie
- ประเภทคำขอ (Register / Login / Google Login / Logout)

## 2. Rule (เงื่อนไข)
- อีเมลต้องอยู่ในรูปแบบที่ถูกต้อง
- รหัสผ่านต้องเป็นไปตามข้อกำหนดของระบบ
- ตรวจสอบข้อมูลผู้ใช้ก่อนเข้าสู่ระบบ
- Google OAuth Token ต้องผ่านการตรวจสอบจาก Google
- Session ต้องมีความถูกต้องและไม่หมดอายุ
- ผู้ใช้เข้าถึงได้เฉพาะข้อมูลตามสิทธิ์ของตนเอง

## 3. Process (กระบวนการ)
1. รับคำขอจาก Frontend
2. ตรวจสอบประเภทคำขอและข้อมูลที่ได้รับ
3. ดำเนินการสมัครสมาชิกหรือเข้าสู่ระบบด้วย Email/Password หรือ Google OAuth
4. ตรวจสอบข้อมูลบัญชีและสิทธิ์ของผู้ใช้
5. สร้าง Session และส่ง Cookie กลับไปยัง Browser
6. ยกเลิก Session เมื่อผู้ใช้ออกจากระบบ

## 4. Output (ข้อมูลส่งออก)

**กรณีสำเร็จ**
- User ID
- Session / Cookie
- ข้อมูลผู้ใช้และสิทธิ์ (User Role)
- สถานะการเข้าสู่ระบบ

**กรณีผิดพลาด**
- Error Code
- Error Message
- สถานะ: `Failed`