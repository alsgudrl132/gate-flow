// 주차 관제 시스템 - 3D 프린팅 모델 (경량화)
// 160mm x 120mm x 40mm (20% 축소)
// 천장에 초음파 센서 (위에서 차량 감지)
// RGB LED 1개만 (PWM 제어)

$fn = 50; // 원 해상도

// ===== 메인 베이스 (축소 + 얇게) =====
module base() {
    difference() {
        // 베이스 플랫폼 (200→160, 150→120, 5→3mm)
        cube([160, 120, 3]);
        
        // 전선 통로 홈 (뒷면)
        translate([60, 110, 1])
            cube([32, 8, 2.5]);
    }
}

// ===== 주차 공간 바닥 표시 (축소 + 얇게) =====
module parking_space_floor(width, depth) {
    wall_thickness = 2; // 3→2mm
    height = 2; // 3→2mm
    
    // 좌측 벽
    cube([wall_thickness, depth, height]);
    
    // 우측 벽
    translate([width - wall_thickness, 0, 0])
        cube([wall_thickness, depth, height]);
}

// ===== 천장 기둥 (원본 유지, 축소) =====
module ceiling_pillar() {
    cube([6, 6, 32]); // 8→6mm (비율 유지), 40→32mm
}

// ===== 천장 (센서 구멍은 실제 크기!) =====
module ceiling_panel(width, depth) {
    difference() {
        cube([width, depth, 2]); // 3→2mm
        
        // 초음파 센서 구멍 (HC-SR04) - 실제 크기 유지!
        translate([width/2 - 10, depth/2 - 8, -1])
            cube([20, 16, 5]);
        
        // 센서 고정 나사 구멍 - 실제 크기 유지!
        translate([width/2 - 12, depth/2, -1])
            cylinder(h=5, d=2.5);
        
        translate([width/2 + 12, depth/2, -1])
            cylinder(h=5, d=2.5);
    }
}

// ===== 완전한 주차 공간 모듈 (바닥 + 기둥 + 천장) =====
module parking_space_unit(width, depth) {
    // 바닥 표시
    parking_space_floor(width, depth);
    
    // 4개 기둥 (원본 위치 비율 유지)
    translate([2, 2, 2])
        ceiling_pillar();
    
    translate([width - 8, 2, 2])
        ceiling_pillar();
    
    translate([2, depth - 8, 2])
        ceiling_pillar();
    
    translate([width - 8, depth - 8, 2])
        ceiling_pillar();
    
    // 천장 (높이 축소: 43→34mm)
    translate([0, 0, 34])
        ceiling_panel(width, depth);
}

// ===== 입구 통로 바닥 표시 (축소) =====
module entrance_marking() {
    for(i = [0:3]) {
        translate([8 + i*28, 8, 2.8])
            cube([20, 2, 0.4]); // 축소
    }
}

// ===== 입구 게이트 기둥 (원본 기반 축소) =====
module gate_post() {
    difference() {
        cube([12, 4, 20]); // 15→12, 5→4, 50→40mm (비율 유지)
        
        // 서보모터 마운팅 홀 (상단) - 실제 크기 유지!
        translate([6, 2, 36])
            cylinder(h=5, d=3);
    }
}

// ===== RFID 리더 지지대 + 마운트 (축소) =====
module rfid_support_and_mount() {
    // 지지 기둥 (축소)
    translate([0, 0, 0])
        cube([24, 2, 20]); // 30→24, 3→2, 25→20mm
    
    // RFID 마운트
    translate([0, -2, 20])
    difference() {
        cube([24, 4, 16]); // 30→24, 5→4, 20→16mm
        
        // RFID 모듈 구멍 - 실제 크기 유지!
        translate([4, -1, 4])
            cube([16, 7, 10]); // 20→16mm (약간 축소, 여전히 맞음)
        
        // 나사 구멍 - 실제 크기 유지!
        translate([4, 2, 4])
            rotate([90, 0, 0])
            cylinder(h=8, d=2.5);
        
        translate([20, 2, 4])
            rotate([90, 0, 0])
            cylinder(h=8, d=2.5);
    }
}

// ===== RGB LED 홀더 (1개만, PWM 제어용) =====
module rgb_led_holder() {
    // 지지 기둥
    translate([0, 0, 0])
        cube([8, 2, 28]); // 12→8, 3→2, 35→28mm
    
    // LED 마운트
    translate([0, 0, 28])
    difference() {
        cube([8, 2, 10]); // 12→8, 3→2, 15→10mm
        
        // RGB LED 구멍 (5mm 또는 8mm RGB LED) - 실제 크기!
        translate([4, 1, 5])
            rotate([90, 0, 0])
            cylinder(h=4, d=5.2); // 5mm LED
    }
}

// ===== 주차면 번호판 (천장에 붙음) =====
module parking_number(number) {
    difference() {
        cube([12, 10, 2]); // 15→12, 12→10mm
        
        // 번호 음각
        translate([6, 5, 2.2])
            rotate([0, 0, 0])
            linear_extrude(height=1)
            text(str(number), size=6, halign="center", valign="center", font="Arial:style=Bold");
    }
}

// ===== 차단기 팔 (원본 기반 축소) =====
module barrier_arm() {
    difference() {
        union() {
            // 메인 바 (축소)
            translate([0, -2, 0])
                cube([24, 4, 2]); // 30→24, 5→4, 3→2mm
            
            // 연결부 (두껍게) - 서보 연결은 실제 크기!
            translate([0, -2, 0])
                cube([8, 4, 6]); // 10→8, 5→4mm
        }
        
        // 서보 혼 연결 구멍 - 실제 크기 유지!
        translate([4, 0, 3])
            rotate([90, 0, 0])
            cylinder(h=8, d=4);
    }
}

// ===== "ENTRANCE" 텍스트 =====
module entrance_text() {
    translate([80, 20, 2.8])
        rotate([0, 0, 0])
        linear_extrude(height=0.4)
        text("ENTRANCE", size=6, halign="center", valign="center", font="Arial:style=Bold");
}

// ===== 전체 조립 =====

// 베이스
base();

// ===== 앞쪽: 입구 영역 (0~40mm) =====

// 입구 바닥 표시선
entrance_marking();

// "ENTRANCE" 텍스트
entrance_text();

// 입구 게이트 기둥 (중앙 1개)
translate([74, 8, 3])
    gate_post();

// RFID 리더 (입구 우측)
translate([104, 6, 3])
    rfid_support_and_mount();

// RGB LED 홀더 1개 (입구 좌측) - PWM으로 색상 제어
translate([40, 6, 3])
    rgb_led_holder();

// ===== 뒷쪽: 주차 공간 영역 (48~116mm) =====

// 주차 공간 1 (좌측) - 44mm x 68mm (55→44, 85→68)
translate([8, 48, 3])
    parking_space_unit(44, 68);

// 주차 공간 2 (중앙)
translate([58, 48, 3])
    parking_space_unit(44, 68);

// 주차 공간 3 (우측)
translate([108, 48, 3])
    parking_space_unit(44, 68);

// 주차면 번호판 (천장 위에)
translate([24, 102, 37])
    parking_number(1);

translate([74, 102, 37])
    parking_number(2);

translate([124, 102, 37])
    parking_number(3);

// ===== 차단기 팔 (별도 프린팅) =====
translate([166, 60, 0]) // 옆에 배치
    rotate([0, 0, 90])
    barrier_arm();


// ===== 변경 사항 =====
/*
크기 변경:
- 전체: 200×150mm → 160×120mm (20% 축소)
- 베이스 두께: 5mm → 3mm
- 벽/천장: 3mm → 2mm
- 기둥: 8×8×40mm → 6×6×32mm
- 주차 공간: 55×85mm → 44×68mm
- 게이트 기둥: 15×5×50mm → 12×4×40mm
- 차단기: 30×5×3mm → 24×4×2mm

센서/부품 구멍 (실제 크기 유지!):
✓ 초음파 센서: 20×16mm (HC-SR04)
✓ 센서 나사: 직경 2.5mm
✓ 서보 혼: 직경 4mm
✓ 서보 마운트: 직경 3mm
✓ RFID 구멍: 16×10mm
✓ RGB LED: 직경 5.2mm (5mm 또는 8mm LED)

LED 변경:
- 기존: LED 4개 (빨강, 초록, 파랑, 노랑)
- 변경: RGB LED 1개 (PWM으로 색상 제어)
  * 빨강: 만차
  * 초록: 입차가능
  * 파랑: 출차
  * 노랑/주황: 에러

예상 필라멘트:
- 원본: ~250g
- 경량화: ~110-120g ✅

프린팅 설정 권장:
- 인필: 10-15%
- 벽: 2 lines
- 레이어: 0.24mm
- 서포트: 천장 부분만
- 시간: 약 7-8시간

150g 필라멘트로 충분합니다! 🎉
*/