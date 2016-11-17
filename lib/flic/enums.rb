module Flic
  module Enums
    Bool = [false, true]
    CreateConnectionChannelError = %i|NoError MaxPendingConnectionsReached|
    ConnectionStatus = %i|disconnected connected ready|
    DisconnectReason = %i|Unspecified ConnectionEstablishmentFailed TimedOut BondingKeysMismatch|
    RemovedReason = %i|RemovedByThisClient ForceDisconnectedByThisClient ForceDisconnectedByOtherClient ButtonIsPrivate VerifyTimeout InternetBackendError InvalidData|
    ClickType = %i|down up click single_click double_click hold|
    BdAddrType = %i|public random|
    LatencyMode = %i|normal low high|
    BluetoothControllerState = %i|detached resetting attached|
    ScanWizardResult = %i|success cancelled_by_user failed_timeout button_is_private bluetooth_unavailable internet_error invalid_data|

    def self.coded(enum, value)
      enum = Enums.const_get(enum)
      enum.index(value)
    end

    def self.decoded(enum, index)
      enum = Enums.const_get(enum)
      enum[index]
    end
  end
end
