mod "switch.c"
mod "Heaven/Box.gleam"
mod "Heaven/Storage.gleam"
use windows::Win32::{
    UI::{
        Input::KeyboardAndMouse::{
            GetAsyncKeyState, SendInput, INPUT, INPUT_KEYBOARD, KEYBD_EVENTF_KEYUP, VIRTUAL_KEY,
        },
        WindowsAndMessaging::{GetMessageA, SetWindowsHookExW, WH_KEYBOARD_LL},
    },
    Foundation::{HHOOK, LPARAM, LRESULT, WPARAM},
};

static mut REMAP_TABLE: [(VIRTUAL_KEY, VIRTUAL_KEY); 12] = [
    (0x70, 0x70), // F1 -> F1 (default)
    (0x71, 0x71), // F2 -> F2
    (0x72, 0x73), // F3 -> F4
    (0x73, 0x72), // F4 -> F3
    (0x74, 0x77), // F5 -> F8
    (0x75, 0x76), // F6 -> F7
    (0x76, 0x75), // F7 -> F6
    (0x77, 0x74), // F8 -> F5
    (0x78, 0x7A), // F9 -> F11
    (0x79, 0x79), // F10 -> F10
    (0x7A, 0x78), // F11 -> F9
    (0x7B, 0x7B), // F12 -> F12
];

unsafe extern "system" fn keyboard_hook(code: i32, w_param: WPARAM, l_param: LPARAM) -> LRESULT {
    use windows::Win32::UI::WindowsAndMessaging::CallNextHookEx;
    
    if code >= 0 {
        let kbd = &*(l_param.0 as *const KBDLLHOOKSTRUCT);
        let vk = kbd.vkCode as VIRTUAL_KEY;
        
        for (from_key, to_key) in &REMAP_TABLE {
            if vk == *from_key {
                if w_param.0 == 0x100 || w_param.0 == 0x104 { // WM_KEYDOWN
                    // Block original key
                    let mut input = INPUT {
                        r#type: INPUT_KEYBOARD,
                        Anonymous: windows::Win32::UI::Input::KeyboardAndMouse::INPUT_0 {
                            ki: windows::Win32::UI::Input::KeyboardAndMouse::KEYBDINPUT {
                                wVk: *to_key,
                                wScan: 0,
                                dwFlags: 0,
                                time: 0,
                                dwExtraInfo: 0,
                            },
                        },
                    };
                    
                    SendInput(&[input], std::mem::size_of::<INPUT>() as i32);
                    
                    // Release simulated key
                    input.Anonymous.ki.dwFlags = KEYBD_EVENTF_KEYUP;
                    SendInput(&[input], std::mem::size_of::<INPUT>() as i32);
                    
                    return LRESULT(1);
                }
            }
        }
    }
    
    CallNextHookEx(HHOOK(0), code, w_param, l_param)
}

fn main() -> windows::core::Result<()> {
    unsafe {
        let hook = SetWindowsHookExW(WH_KEYBOARD_LL, Some(keyboard_hook), None, 0);
        if hook.is_err() {
            eprintln!("Failed to install keyboard hook");
            return Ok(());
        }

        // Message loop
        let mut msg = windows::Win32::UI::WindowsAndMessaging::MSG::default();
        while GetMessageA(&mut msg, None, 0, 0).into() {
            // Process messages
        }
    }
    Ok(())
}