# Vercel + GitHub 배포 가이드 (온새미로교회)

## 1. GitHub 저장소 만들기

1. [github.com](https://github.com) 로그인
2. 오른쪽 상단 **+** → **New repository**
3. 저장소 이름: `onsaemiro-church` (또는 원하는 이름)
4. **Public** 선택
5. **Create repository** 클릭

---

## 2. 프로젝트를 GitHub에 올리기

### 방법 A: GitHub 웹에서 올리기

1. 저장소 페이지에서 **"uploading an existing file"** 링크 클릭
2. 프로젝트 폴더의 **모든 파일**을 끌어다 놓기  
   (index.html, gallery.html, news.html, 이미지·폴더 등)
3. 하단 **Commit changes** 클릭

### 방법 B: Git 명령어로 올리기 (로컬에 Git이 있을 때)

프로젝트 폴더에서 터미널(명령 프롬프트)을 열고:

```bash
git init
git add .
git commit -m "Initial commit: 온새미로교회 웹사이트"
git branch -M main
git remote add origin https://github.com/내사용자이름/onsaemiro-church.git
git push -u origin main
```

(`내사용자이름`과 `onsaemiro-church`를 본인 저장소 주소로 바꾸세요.)

---

## 3. Vercel에 연결하기

1. [vercel.com](https://vercel.com) 로그인 (GitHub 계정으로 로그인 권장)
2. **Add New...** → **Project** 클릭
3. **Import Git Repository**에서 방금 만든 저장소 선택  
   (안 보이면 **Configure GitHub Account**에서 저장소 접근 허용)
4. **Import** 클릭
5. 설정 확인:
   - **Framework Preset**: Other (또는 None)
   - **Root Directory**: 비워두기 (`.` 그대로)
   - **Build Command**: `npm install && npm run build`
   - **Output Directory**: 비워두기 (정적 사이트라서)
6. **Deploy** 클릭

---

## 4. 배포 완료 후

- 몇 분 안에 **배포 URL**이 생성됩니다 (예: `https://onsaemiro-church.vercel.app`)
- **Domains** 메뉴에서 커스텀 도메인 연결 가능
- GitHub에 새로 push할 때마다 자동으로 다시 배포됩니다

---

## 5. 주의사항

- **Supabase** 키·URL은 그대로 두면 됩니다 (클라이언트용이라 배포 환경에서도 동작)
- **YouTube 예배실황**: Vercel 배포 시 `api/youtube-latest.js`가 서버리스 함수로 동작하여 최신 영상 ID를 5분간 캐싱합니다. 다른 호스팅 환경에서는 allorigins 프록시로 폴백됩니다.
- 이미지·파일 경로는 `./` 상대 경로라 그대로 사용 가능
- 랜딩 배경 이미지는 `hero` 폴더의 `hero01.webp` ~ `hero11.webp`를 사용합니다. 없으면 기본 이미지가 보입니다.
