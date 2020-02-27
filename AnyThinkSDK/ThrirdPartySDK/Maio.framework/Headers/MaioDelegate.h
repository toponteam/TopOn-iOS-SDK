//
//  MaioDelegate.h
//  Maio
//
//
//

/**
 *  maio SDK のエラー種別（アプリ側への通知内容）
 */
typedef NS_ENUM(NSInteger, MaioFailReason) {
    /// 不明なエラー
    MaioFailReasonUnknown = 0,
    /// 広告在庫切れ
    MaioFailReasonAdStockOut,
    /// ネットワーク接続エラー
    MaioFailReasonNetworkConnection,
    /// HTTP status 4xx クライアントエラー
    MaioFailReasonNetworkClient,
    /// HTTP status 5xx サーバーエラー
    MaioFailReasonNetworkServer,
    /// SDK エラー
    MaioFailReasonSdk,
    /// クリエイティブダウンロードのキャンセル
    MaioFailReasonDownloadCancelled,
    /// 動画再生エラー
    MaioFailReasonVideoPlayback,
    /// メディアID異常エラー
    MaioFailReasonIncorrectMediaId,
    /// ゾーンID異常エラー
    MaioFailReasonIncorrectZoneId,
    /// 表示するための要素を見つけられなかった
    MaioFailReasonNotFoundViewContext,
};


/**
 *  maio SDK からの通知を受け取るデリゲート
 */
@protocol MaioDelegate <NSObject>

@optional

/**
 *  全てのゾーンの広告表示準備が完了したら呼ばれます。
 */
- (void)maioDidInitialize;

/**
 *  広告の配信可能状態が変更されたら呼ばれます。
 *
 *  @param zoneId   広告の配信可能状態が変更されたゾーンの識別子
 *  @param newValue 変更後のゾーンの状態。YES なら配信可能
 */
- (void)maioDidChangeCanShow:(NSString *)zoneId newValue:(BOOL)newValue;

/**
 *  広告が再生される直前に呼ばれます。
 *  最初の再生開始の直前にのみ呼ばれ、リプレイ再生の直前には呼ばれません。
 *
 *  @param zoneId  広告が表示されるゾーンの識別子
 */
- (void)maioWillStartAd:(NSString *)zoneId;

/**
 *  広告の再生が終了したら呼ばれます。
 *  最初の再生終了時にのみ呼ばれ、リプレイ再生の終了時には呼ばれません。
 *
 *  @param zoneId  広告を表示したゾーンの識別子
 *  @param playtime 動画の再生時間（秒）
 *  @param skipped  動画がスキップされていたら YES、それ以外なら NO
 *  @param rewardParam  ゾーンがリワード型に設定されている場合、予め管理画面にて設定してある任意の文字列パラメータが渡されます。それ以外の場合は nil
 */
- (void)maioDidFinishAd:(NSString *)zoneId playtime:(NSInteger)playtime skipped:(BOOL)skipped rewardParam:(NSString *)rewardParam;

/**
 *  広告がクリックされ、ストアや外部リンクへ遷移した時に呼ばれます。
 *
 *  @param zoneId  広告がクリックされたゾーンの識別子
 */
- (void)maioDidClickAd:(NSString *)zoneId;

/**
 *  広告が閉じられた際に呼ばれます。
 *
 *  @param zoneId  広告が閉じられたゾーンの識別子
 */
- (void)maioDidCloseAd:(NSString *)zoneId;

/**
 *  SDK でエラーが生じた際に呼ばれます。
 *
 *  @param zoneId  エラーに関連するゾーンの識別子
 *  @param reason   エラーの理由を示す列挙値
 */
- (void)maioDidFail:(NSString *)zoneId reason:(MaioFailReason)reason;

@end
