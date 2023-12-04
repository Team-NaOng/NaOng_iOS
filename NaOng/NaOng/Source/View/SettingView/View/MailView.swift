//
//  MailView.swift
//  NaOng
//
//  Created by seohyeon park on 2023/08/23.
//

import SwiftUI
import MessageUI
import DeviceKit

struct MailView: UIViewControllerRepresentable {
  @Environment(\.presentationMode) var presentation

  class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
    @Binding var presentation: PresentationMode

    init(presentation: Binding<PresentationMode>) {
      _presentation = presentation
    }

    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult,
                               error: Error?) {

      $presentation.wrappedValue.dismiss()
    }
  }

  func makeCoordinator() -> Coordinator {
    Coordinator(presentation: presentation)
  }

  func makeUIViewController(context: UIViewControllerRepresentableContext<MailView>) -> MFMailComposeViewController {
    let body = """

        Device Model: \(Device.current)
        Device OS: \(UIDevice.current.systemVersion)
        App Name: \(Bundle.main.displayName)
        App Version: \(Bundle.main.appVersion)
    
        "아래에 문의 및 의견을 적어주세요."
        --------------------------------------
    """
    let mailComposeViewController = MFMailComposeViewController()
    mailComposeViewController.mailComposeDelegate = context.coordinator
    mailComposeViewController.setSubject("문의 및 의견")
    mailComposeViewController.setToRecipients(["parksseo0418@gmail.com"])
    mailComposeViewController.setMessageBody(body, isHTML: false)
    mailComposeViewController.accessibilityElementDidLoseFocus()
    return mailComposeViewController
  }

  func updateUIViewController(_ uiViewController: MFMailComposeViewController,
                              context: UIViewControllerRepresentableContext<MailView>) {
  }

  static var canSendMail: Bool {
    MFMailComposeViewController.canSendMail()
  }
}
