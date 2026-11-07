# Audio API

รับไฟล์เสียง เริ่มวิเคราะห์ ติดตามสถานะ และดึงผลวิเคราะห์ของผู้ใช้

## Endpoints

  Method   Endpoint                          หน้าที่
  -------- --------------------------------- ------------------------
  POST     `/api/audio/upload`               รับไฟล์เสียงและเริ่มวิเคราะห์
  GET      `/api/audio/jobs/{job_id}`        ตรวจสอบสถานะ Job
  GET      `/api/audio/records`              ดึงประวัติการวิเคราะห์
  GET      `/api/audio/records/{audio_id}`   ดึงผลวิเคราะห์รายรายการ

## 1. Upload Audio

`POST /api/audio/upload`

-   Request: `multipart/form-data` พร้อมไฟล์เสียง poem_id และ `version=1.0,
-   Authentication: ต้อง Login 
-   Backend ตรวจสอบไฟล์ บันทึกลง Audio Storage และสร้าง Audio Record กับ
    Analysis Job
-   ส่ง Job ให้ Background Worker ประมวลผล
-   Response: HTTP `202 Accepted`

ตัวอย่าง Response:

``` json
{
  "version": "1.0",
  "data": {
    "success": true,
    "audio_id": 123,
    "job_id": "job_abc123",
    "status": "Pending"
  }
}
```

## 2. Check Job Status

`GET /api/audio/jobs/{job_id}`

-   Authentication: ต้อง Login และเป็นเจ้าของ Job
-   Response: `job_id`, `status` และ `result_available`
-   Status: `Pending`, `Processing`, `Completed`, `Failed`

## 3. Get Audio Records

`GET /api/audio/records`

-   Authentication: ต้อง Login
-   ดึงประวัติของผู้ใช้ปัจจุบัน
-   รองรับ Pagination
-   เพิ่ม poem_id ใน response 

## 4. Get Audio Result

`GET /api/audio/records/{audio_id}`

-   Authentication: ต้อง Login และเป็นเจ้าของ Audio Record
-   คืนข้อมูลเสียงและผลวิเคราะห์ เช่น คะแนนและ Feedback
-   เพิ่ม poem_id ใน Response

## 5. GET Dashboard response

`GET /api/dashboard`

- Authentication: ต้อง Login และเป็นเจ้าของ Audio Record
- เรียกดูข้อมูล Dashbaord
- เพิ่มข้อมูล poem_id เพื่อใช้แยกประวัติตามบทกลอน
## Important Rules

-   ผู้ใช้ส่งเสียงเพียงครั้งเดียวผ่าน Upload API
-   ไม่ต้องมี Analyze API แยก เพราะ Backend เริ่มงานวิเคราะห์ให้อัตโนมัติ
-   Frontend ไม่ส่ง `user_id` เพื่อกำหนดเจ้าของข้อมูล
-   Backend ตรวจสอบ Ownership ของ `job_id` และ `audio_id` ทุกครั้ง
-   หากประมวลผลไม่สำเร็จ ให้เปลี่ยนสถานะเป็น `Failed` และบันทึก Error ที่เหมาะสม
