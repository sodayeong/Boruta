### Boruta
https://sodayeong.tistory.com/219

1. 모든 변수를 복사 ➔ shadow features or permuted copies. 
  - 원본 데이터의 독립 변수가 5개 미만인 경우 기존 변수를 복사본으로 만들어 5개 이상 만듦.
2. 복사한 변수를 타겟 변수에 uncorrelated 하게 만들기 위해 랜덤하게 섞고 원 자료와 결합. 
3. 결합된 데이터와 원 데이터에 대해 랜덤포레스트 모형을 생성하고, Z-score를 계산.
  - [(각 트리에 대한 정확도 손실값 - 전체 트리의 정확도 손실의 평균) / 정확도 손실 표준편차]
4. shadow 변수들 중 가장 높은 Z-score를 찾는다. (MSZA, Max Z-score among shadow attributes) 
5. 원 자료에 대한 Z-score > MSZA인 경우 Hit +1 (이는 MZSA보다 클 때 중요한 변수를 표시하는 수단)
  - 통계적으로 유의수준에서 Z-score < MSZA인 경우, 해당 피쳐를 중요하지 않은 피쳐로 드랍한다. 
  - 통계적으로 유의수준에서 Z-score > MSZA인 경우, 해당 피쳐를 중요한 변수로 둔다. 
6. 위의 과정을 랜덤포레스트가 수행되는 횟수만큼 또는 모든 변수들이 중요한 변수와 중요하지 않은 변수로 tagged 될 때까지 반복.
