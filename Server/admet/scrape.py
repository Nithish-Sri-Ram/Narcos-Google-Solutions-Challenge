from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import time
import pandas as pd
import os
import shutil
import re

def automate_download(unique_id, smiles_code="CC(C)CO"):
    options = webdriver.ChromeOptions()
    
    options.add_argument("--start-maximized")
    options.add_argument("--headless")
    
    current_dir = os.getcwd()
    download_dir = os.path.join(current_dir, "downloads")
    
    if not os.path.exists(download_dir):
        os.makedirs(download_dir)
    
    prefs = {
        "download.default_directory": download_dir,
        "download.prompt_for_download": False,
        "download.directory_upgrade": True,
        "safebrowsing.enabled": False
    }
    options.add_experimental_option("prefs", prefs)
    
    driver = webdriver.Chrome(options=options)
    
    try:
        driver.get("http://www.swissadme.ch/index.php")
        
        clear_btn = WebDriverWait(driver, 10).until(
            EC.element_to_be_clickable((By.XPATH, '//*[@id="myForm"]/div/input[2]'))
        )
        clear_btn.click()

        text_input = WebDriverWait(driver, 10).until(
            EC.presence_of_element_located((By.XPATH, '//*[@id="smiles"]'))
        )
        text_input.send_keys(smiles_code)
        
        button = WebDriverWait(driver, 10).until(
            EC.element_to_be_clickable((By.XPATH, '//*[@id="submitButton"]'))
        )
        button.click()
        
        time.sleep(15)

        molecule_img = None
        base64_image = None
        
        try:
            molecule_img = WebDriverWait(driver, 10).until(
                EC.presence_of_element_located((By.XPATH, '//*[@id="mol-cell-1"]/img'))
            )
            
            img_src = molecule_img.get_attribute('src')
            if img_src and 'base64' in img_src:
                base64_image = img_src
                print("Successfully extracted base64 image data")
        except Exception as e:
            print(f"Error getting molecule image: {e}")

        download_button = WebDriverWait(driver, 10).until(
            EC.element_to_be_clickable((By.XPATH, '//*[@id="content"]/div[7]/a[1]'))
        )
        download_button.click()
        
        time.sleep(5)
        
        original_file_path = os.path.join(download_dir, "swissadme.csv")
        
        new_file_name = f"swissadme_{unique_id}.csv"
        new_file_path = os.path.join(download_dir, new_file_name)
        
        timeout = 30
        elapsed = 0
        while not os.path.exists(original_file_path) and elapsed < timeout:
            time.sleep(1)
            elapsed += 1
        
        if os.path.exists(original_file_path):
            shutil.copy2(original_file_path, new_file_path)
            
            print(f"Original CSV file saved at: {original_file_path}")
            print(f"CSV file with unique ID saved at: {new_file_path}")
            
            df = pd.read_csv(original_file_path)
            
            if base64_image:
                df['MoleculeImage_Base64'] = base64_image
                
                df.to_csv(new_file_path, index=False)
                print(f"CSV file updated with base64 image data")
            
            os.remove(original_file_path)
            print(f"Original file deleted: {original_file_path}")
            
            print(f"CSV file loaded successfully. Found {len(df)} rows.")
            print(df.head())
            
            return df, None, new_file_path
        else:
            print(f"File download failed or timeout exceeded: {original_file_path}")
            return None, None, None
            
    finally:
        driver.quit()

if __name__ == "__main__":
    unique_id = "test123"
    
    data, original_path, unique_id_path = automate_download(unique_id)
    
    if data is not None:
        print("Data ready for further processing")
        print(f"File saved at: {unique_id_path}")