# 이어버스

버스 정보 시스템의 실시간 정보 누락에 대비 가능한 새로운 버스 정보 시스템

실시간 버스 정보 누락이 발생했을 때, 기계학습 모델을 통해 예측정보를 제공하는 버스 정보 시스템 애플리케이션

Flutter를 통해 구현한 크로스플랫폼

## 기능

### 버스 정류장 지도
<img src="https://github.com/user-attachments/assets/b49ef075-98e6-4f10-9f3d-78027dde8361" width="200" height="400"/>

- 현재 지도 화면 내의 정류장에 클릭할 수 있는 마커를 설치 (마커 클릭 시, 해당 정류장 정보 페이지로 이동)
- 지도를 이동하면 다시 지도 내의 마커를 최신화, 정류장 위치를 지속적으로 알려줌
- 일정 수준 이상 확대해야 마커 확인 가능
- 위치 정보 이용을 동의하면 '내 위치' 버튼을 통해 현재 기기의 위치를 찾아서 지도 이동 가능

### 정류장 정보
<img src="https://github.com/user-attachments/assets/85113150-f0bd-441d-b567-66c043f89e86" width="200" height="400"/>

- 정류장을 중심으로 지도 이동, 정보를 보면서 지도 이동 및 확대 가능
- 정류장을 지나는 버스 리스트 및 정보 제시 (버스 번호, 가는 방면, 좌석 버스, 일반 버스)
- 도착 예정 정보가 있을 시, 도착까지 남은 시간 제시
- 오른쪽 하단 새로고침 버튼을 누르면 페이지 새로 고침
- 즐겨찾기(☆)를 누르면 즐겨찾기 페이지에 추가, 다시 누르면 제거

### 미니 도착 정보
<img src="https://github.com/user-attachments/assets/b69a92f5-db1b-4047-b7d3-ec834b22f0e0" width="200" height="400"/>

- 정류장 정보 페이지에서 버스를 길게 누르면 메인 화면에 미니 도착 정보 추가 가능 (최대 1개)
- 메인 화면에서 선택 버스가 해당 정류장까지 도착하는데 걸리는 시간과 남은 정류장 수를 제시
- 새로고침 버튼을 통해 새로 고침
- X 버튼을 통해 닫기

### 버스 위치 정보
<img src="https://github.com/user-attachments/assets/bf7d5db1-6993-4c93-a3bb-0a7647bfb5b0" width="200" height="400"/>

- 버스의 노선 경로를 지도에 선으로 표시, 정보를 보면서 지도 이동 및 확대 가능
- 버스의 노선 정류장 리스트 및 정보 제시 (정류장명, 정류장번호)
- 버스 위치 정보가 있을 시, 리스트 옆에 버스 마크 표시
- 정류장 클릭 시, 지도가 해당 정류장을 이동
- 오른쪽 하단 새로고침 버튼을 누르면 페이지 새로 고침
- 즐겨찾기(☆)를 누르면 즐겨찾기 페이지에 추가, 다시 누르면 제거

### 검색
<img src="https://github.com/user-attachments/assets/53e89b2b-e0fb-4056-b857-b1c9c9d5e547" width="200" height="400"/>
<img src="https://github.com/user-attachments/assets/c23034cc-0dd3-4fba-a28d-d787e5c06c6e" width="200" height="400"/>

(왼쪽 : 버스 번호(190) 입력 / 오른쪽  : 정류장명(금오공대) 입력)

- 찾는 버스 번호 혹은 정류장명을 입력하면 일치하는 결과를 바로 제시
- 클릭하면 해당 정보 페이지로 이동

### 즐겨찾기
<img src="https://github.com/user-attachments/assets/1cf83832-a024-4078-89a5-98eeb1259cd7" width="200" height="400"/>

- 즐겨찾기에 추가한 버스 및 정류장을 로컬 캐시로 저장
- 클릭하면 해당 정보 페이지로 이동
- X를 누르면 삭제

### 접근성
<img src="https://github.com/user-attachments/assets/e7c2001b-4e04-494b-918a-00cc5a68f2cf" width="200" height="400"/>
<img src="https://github.com/user-attachments/assets/7bff8753-5d33-43c8-8a34-de3b372a4083" width="200" height="400"/>

(왼쪽 : OFF / 오른쪽 : ON)

- 초기 사용자나 스마트폰의 사용이 낯선 이용자들(어린이, 노인 등)을 위한 도움말
- 메인 화면의 사람 모양 버튼을 누르면 페이지를 이동할 때마다 간단한 사용 가이드를 볼 수 있음
- 버튼을 눌러 ON / OFF로 전환 가능

### AI 모드 버스 정보
<img src="https://github.com/user-attachments/assets/d1be9363-0108-4801-8270-ba46db9aea48" width="200" height="400"/>
<img src="https://github.com/user-attachments/assets/d9549f8c-1ccf-4d03-8ecd-e65eabb7ae36" width="200" height="400"/>

(왼쪽 : 버스 정보(196) / 오른쪽 : 정류장 정보(금오공대종점))

- 기계학습 시킨 모델을 통해 대신 정보를 예측하여 정보 제시 가능
- 기본 API를 우선적으로 사용하게끔 설정, 일정 시간 API에 업데이트가 없거나 손실될 경우, 예측 모델을 통해 대신 정보를 요청
- 기본 페이지와 차이성을 보이기 위해 제목을 파란색으로 지정
- 모델을 통한 예측 정보일 경우 기존 색(검정색)과 다른 파란색으로 표시
- 실제 정보와 다를 수 있다는 주의 문구를 배경에 제시
- 서비스 정류장 : 금오공대종점, 금오공대입구(금오공대종점방면), 금오공대입구(옥계중학교방면)
- 서비스 버스 : 10번(구미역(중앙시장) 방면), 196번(구미역(중앙시장) 방면), 960번(구미역(중앙시장) 방면), 80번(인동차고지 방면)

### 설정
<img src="https://github.com/user-attachments/assets/5d194484-e244-4c34-bc40-38ca96ed1c98" width="200" height="400"/>

- 언어 설정 : 구미에는 외국인 거주자도 많아 영어로도 이용 가능
- 글자 크기 : 글씨가 잘 안 보이는 노인 분들을 위한 글자 크기 조절 가능
- AI 모드 : AI 모드가 필요없는 이용자들은 따로 설정하여 사용하지 않아도 됨

#### 언어 설정 (영어)
<img src="https://github.com/user-attachments/assets/2289c214-fbce-4754-b1aa-f5992e6c1074" width="200" height="400"/>

#### 글자 크기 (크게)
<img src="https://github.com/user-attachments/assets/70df31c3-2950-4e50-afe0-cf9eee896cbe" width="200" height="400"/>

## 시연 동영상

Android : <https://www.youtube.com/shorts/VvfuEnAlxsk>

iOS : <https://www.youtube.com/shorts/YSINX8eiB00>
