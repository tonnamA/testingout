
{
  "audio_id": 1024,
  "analysis_status": "success",

  "metadata": {
    "duration": 85.6,
    "sample_rate": 16000,
    "template_id": 1
  },

  "score": {
    "overall": 82.5,
    "dimensions": {
      "pitch": 85.0,
      "duration": 78.0,
      "pause": 84.5
    },
    "n_anomalies": 8,
    "n_high": 2,
    "n_medium": 4,
    "n_low": 2
  },

  "feedback": [
    {
      "rank": 1,
      "type": "PITCH_TOO_HIGH",
      "syllable": "ฟ้า",
      "stanza": 1,
      "verse": 2,
      "position_in_verse": 3,
      "severity": "high",
      "value": 320.5,
      "threshold": 280.0,
      "time_range": [12.5, 13.2],
      "message": "ระดับเสียงสูงกว่าค่าที่กำหนด",
      "action": "ลองลดระดับเสียงในพยางค์นี้"
    }
  ],

  "all_anomalies": [
    {
      "type": "PITCH_TOO_HIGH",
      "syllable": "ฟ้า",
      "stanza": 1,
      "verse": 2,
      "position_in_verse": 3,
      "severity": "high",
      "value": 320.5,
      "threshold": 280.0,
      "time_range": [12.5, 13.2]
    }
  ]
}


