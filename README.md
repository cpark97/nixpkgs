# sanitized nixpkgs

openclaw가 제거된 nixpkgs. Crowdstrike Falcon이 nixpkgs에 포함된 openclaw를 차단하여 `nix flake update`가 불가능한 문제를 우회합니다.

## 사용법

기존 nixpkgs url을 이 repo url로 교체합니다.

```nix
inputs = {
    nixpkgs.url = "github:cpark97/nixpkgs/nixos-unstable";
};
```

## 지원 채널

- nixos-unstable

## 주의사항

- 원본 nixpkgs의 커밋 sha는 사용할 수 없습니다.

## 업데이트

merge-upstream 액션을 실행하여 업스트림 변경사항을 머지합니다.
