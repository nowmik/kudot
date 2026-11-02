# KU돗을 GitHub에서 개발하기

## 1. 저장소 만들기

1. GitHub 계정에 로그인합니다.
2. 오른쪽 상단 `+` → `New repository`를 누릅니다.
3. Repository name: `KUDot` (자유롭게 변경 가능).
4. `Public` 또는 `Private`을 선택합니다. 공개 전에는 지도 좌표와 위치 제보 정책을 점검하세요.
5. `Add a README file`, `.gitignore`, `license` 자동 생성은 **선택하지 않고** 저장소를 만듭니다.

## 2. 프로젝트 업로드

### 방법 A: GitHub 웹사이트

1. 배포받은 `KUDot_GitHub.zip`을 압축 해제합니다.
2. 새 저장소 페이지에서 `uploading an existing file` 또는 `Add file → Upload files`를 선택합니다.
3. 압축을 푼 폴더 안의 **모든 파일과 폴더를 저장소 루트에** 업로드합니다 (`KUDot.xcodeproj`, `KUDot`, `README.md`, `docs` 등).
4. `.github/workflows/ios-build.yml`, `.gitignore`처럼 점으로 시작하는 파일은 업로드 UI에서 빠질 수 있으므로 업로드 후 반드시 확인하세요. 빠졌다면 CLI 방법을 사용하세요.
5. `Commit changes`를 누릅니다.

**주의:** ZIP 파일 한 개만 올리면 GitHub가 Swift 코드를 파일별로 보여주지 않습니다. 압축 해제 후 내용물을 올려야 합니다.

### 방법 B: Git 명령어 (추천)

```bash
cd /path/to/KUDot_GitHub
git init
git add .
git commit -m "Initial commit: KU돗"
git branch -M main
git remote add origin https://github.com/<YOUR_USERNAME>/KUDot.git
git push -u origin main
```

> 기존에 저장소가 이미 있다면 `git init`과 remote 명령을 무조건 반복하지 말고 해당 저장소의 상태를 확인하세요.

## 3. 자동 빌드 확인

`Actions` 탭 → `iOS Build` 작업을 확인합니다. `main`에 push하거나 Pull Request를 만들면 macOS 러너에서 빌드합니다. 해당 워크플로는 **App Store 배포가 아니라 시뮬레이터 빌드 검사**를 수행합니다.

- `Actions`가 비활성화되어 있다면 저장소 설정에서 사용 허용 여부를 확인합니다.
- 실제 디바이스 설치용 서명은 Mac의 Xcode에서 본인 Team 및 고유 Bundle ID로 설정합니다.
- macOS 러너 사용량과 GitHub 플랜별 한도를 확인하세요.

## 4. 개발 및 협업 루틴

1. 기능별 브랜치 생성: `git checkout -b feature/map-markers`
2. Xcode에서 변경 → 시뮬레이터 실행
3. `git add . && git commit -m "Add map marker filter"`
4. `git push -u origin feature/map-markers`
5. GitHub에서 Pull Request → CI 확인 → 리뷰 → `main` 반영

## 5. 첫 실행의 데이터 상태

- 건물 14개: 지도용 **기본 참고 좌표**
- 쉼터 기록: **0건**
- 고양이·청설모 발견 기록: **0건**
- 흡연 주의 제보: **0건**
- 사진: **없음**

새 기록은 기기에만 보관됩니다. 아직 다른 학생과 공동 동기화하지 않습니다. Firebase/Supabase 등을 도입하기 전까지는 GitHub 저장소만으로 공동 기록 기능이 작동하지 않습니다.
