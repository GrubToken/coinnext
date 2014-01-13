class App.FinancesView extends App.MasterView

  events:
    "submit #add-wallet-form": "onAddWallet"
    "click .deposit-bt": "onDeposit"
    "click #show-qr-bt": "onShowQrAddress"
    "submit #withdraw-form": "onPay"

  initialize: ()->
    $.subscribe "new-balance", @onNewBalance

  render: ()->
    @renderCopyButton()

  renderCopyButton: ()->
    $copyButton = @$("#copy-address")
    new ZeroClipboard $copyButton[0],
      moviePath: "#{window.location.origin}/ZeroClipboard.swf"

  renderQrAddress: ($qrCnt)->
    $qrCnt.empty()
    new QRCode $qrCnt[0], $qrCnt.data("address")

  onAddWallet: (ev)->
    ev.preventDefault()
    $form = $(ev.target)
    wallet = new App.WalletModel
      currency: $form.find("#currency-type").val()
    wallet.save null,
      success: ()->
        window.location.reload()
      error: (m, xhr)->
        $.publish "error", xhr

  onDeposit: (ev)->
    ev.preventDefault()
    $target = $(ev.target)
    wallet = @collection.get $target.data "id"
    wallet.save {address: "pending"},
      success: ()=>
        @renderWallet wallet
      error: (m, xhr)->
        $.publish "error", xhr

  onShowQrAddress: (ev)->
    ev.preventDefault()
    $qrCnt = @$("#qr-address-cnt")
    if $qrCnt.is ":empty"
      @renderQrAddress $qrCnt
    else
      $qrCnt.toggle()

  onPay: (ev)->
    ev.preventDefault()
    $form = $(ev.target)
    amount = parseFloat $form.find("[name='amount']").val()
    if _.isNumber(amount) and amount > 0
      $form.find("button").attr "disabled", true
      payment = new App.PaymentModel
        wallet_id: $form.find("[name='wallet_id']").val()
        amount: amount
        address: $form.find("[name='address']").val()
      payment.save null,
        success: ()->
          $form.find("button").attr "disabled", false
          $.publish "notice", "Your withdrawal will be processed soon."
        error: (m, xhr)->
          $form.find("button").attr "disabled", false
          $.publish "error", xhr
    else
      $.publish "error", "Please submit a proper amount."

  onNewBalance: (ev, data)=>
    #TODO: Implement