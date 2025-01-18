import Foundation
/// 일일 통계 정보를 나타내는 모델
///
/// 사용자의 일별 활동 통계와 균형 데이터를 표현합니다.
/// - Properties:
///   - id: 통계 데이터 고유 식별자
///   - date: 해당 날짜
///   - userId: 사용자 식별자
///   - balanceData: 일과 균형 데이터
///   - productivityNum: 생산성 지수
///   - tagStats: 태그별 통계 정보
///   - center: 메쉬 그라데이션 중심점 좌표
struct DailyStat: Codable, Identifiable {
    let id: String
    let date: String
    let userId: String
    let balanceData: BalanceData
    let productivityNum: Double
    let tagStats: [TagStat]
    let center: SIMD2<Float>
     
    enum CodingKeys: String, CodingKey {
        case id = "_id"  // MongoDB의 _id를 id로 매핑
        case userId = "user"
        case date, balanceData, productivityNum, tagStats, center
    }
    
    static let empty = DailyStat(
        id: UUID().uuidString,
        date: "emptyData",
        userId: "emptyData",
        balanceData: BalanceData(
            title: "Todo가 없네요 :(",
            message: "아래 + 버튼을 눌러 Todo를 추가해주세요",
            balanceNum: 0
        ),
        productivityNum: 0,
        tagStats: [],
        center: SIMD2<Float>(x: 0.5, y: 0.5)
    )
    
    static let dummyStat =
        DailyStat(
            id: "dummy1",
            date: Date().apiFormat,
            userId: "emptyData",
            balanceData: BalanceData(title: "이상적인 하루", message: "오늘의 일정은 그야말로 이상적이에요. 무엇이 좋았는지 기록해두세요.", balanceNum: 90),
            productivityNum: 85.0,
            tagStats: [
                TagStat(id: "tagDummy1", tag: Tag(id: "tag1", name: "1", color: "FFF700", userId: "dummyUser"), count: 2),
                TagStat(id: "tagDummy2", tag: Tag(id: "tag2", name: "2", color: "4169E1", userId: "dummyUser"), count: 4),
                TagStat( id: "tagDummy3", tag: Tag(id: "tag2", name: "3", color: "00CED1", userId: "dummyUser"), count: 3 )],
            center: SIMD2<Float>(0.4, 0.5)
        )
}

/// 그래프 표시용 일일 통계 모델
///
/// 그래프 시각화에 사용되는 간소화된 일일 통계 정보입니다.
/// - Properties:
///   - id: 통계 데이터 고유 식별자 (날짜와 동일)
///   - date: 해당 날짜
///   - productivityNum: 생산성 지수
struct DailyStat_Graph: Identifiable,Codable,Equatable {
    let id: String
    let date: String
    let productivityNum: Double
    
    init(
        date: String,
        productivityNum: Double
    ) {
        self.id = date
        self.date = date
        self.productivityNum = productivityNum
    }
}

/// 일과 균형 데이터를 나타내는 모델
///
/// 사용자의 일과 균형에 대한 평가와 메시지를 포함합니다.
/// - Properties:
///   - title: 균형 상태 제목
///   - message: 상세 메시지
///   - balanceNum: 균형 점수 (0-100)
struct BalanceData: Codable {
    let title: String 
    let message: String
    let balanceNum: Int
}

/// 태그 통계 정보를 나타내는 모델
///
/// 특정 날짜의 태그별 사용 통계를 표현합니다.
/// - Properties:
///   - id: 태그 통계 고유 식별자
///   - tag: 연관된 태그 정보
///   - count: 사용 횟수
struct TagStat: Codable, Identifiable {
    let id: String
    let tag: Tag
    let count: Int
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"  // tagId를 id로 매핑
        case tag = "tagId"
        case count
    }
}
