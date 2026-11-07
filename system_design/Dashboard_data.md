## 1. Overview – ภาพรวมการฝึก
- จำนวน Audio Records ที่วิเคราะห์สำเร็จ
- คะแนนเฉลี่ยจาก Overall Score
- คะแนนสูงสุด
- ระยะเวลาฝึกสะสมจาก Audio Duration
## 2. Score Overview – คะแนนแต่ละด้าน
- score.overall
- score.dimensions.pitch
- score.dimensions.duration
- score.dimensions.pause
## 3. Progress – พัฒนาการการฝึก
- กราฟ Overall Score ตามเวลา
- เปรียบเทียบคะแนนแต่ละครั้ง
- คะแนนแยกตาม Pitch, Duration และ Pause
- แนวโน้มคะแนนว่าดีขึ้นหรือลดลง
## 4. Anomaly Summary – จุดที่ต้องปรับปรุง
- Pitch Too High
- Pitch Too Low
- Too Fast
- Too Slow
- Verse Pause Missing
- Extra Pause
## 5. Feedback – คำแนะนำจาก Algorithm
## 6. Practice History – ประวัติการฝึก


- Dashboard ควรแสดงคะแนนแยกแต่ละครั้งของแบบฝึก
- Progress ควรใช้ผลวิเคราะห์ที่สำเร็จแล้วหลายครั้ง ไม่ใช่เฉพาะครั้งล่าสุด และ progress ควรอยู่ใน Overview Dashboard คนละหน้ากับ Dashboard / Overview dashboard จะเป็นหน้าที่รวมผลการฝึกของแต่ละ Dashboard มาใส่ไว้เป็น line
- Feedback บน Dashboard ใช้ 5 รายการ ส่วนหน้ารายละเอียดควรดู Anomalies ทั้งหมดได้
- Job ที่ยัง Pending หรือ Processing ต้องแสดงสถานะแยกจากผลคะแนน
- กรณีข้อมูลวิเคราะห์ไม่เพียงพอ ต้องแสดงว่าไม่มีข้อมูลคะแนนในมิตินั้น ไม่ควรแสดงเป็น 0