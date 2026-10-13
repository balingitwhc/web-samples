#==================================================
#  Author   : William Balingit
#  Purpose  : Reads and extracts data from PDF Invoice and transfer's all relevant data into Excel
#==================================================

import openpyxl                 # For Excel files manipulation (read, write, modify)
import pandas as pd             # For data analysis and manipulation
import tabula                   # For extracting tables from PDF Files and convert to usable data for pandas
from PyPDF2 import PdfReader    # For reading the overall document content and information

def extract_tables_from_pdf(pdf_path, excel_path):
    reader = PdfReader(pdf_path)
    num_pages = len(reader.pages) # Number of Pages, usually 12 for this case
    page_range = f"2-{num_pages}"

    # Define the areas for page 1 and pages 2 onwards
    area_1 = (260, 10, 610, 780)  # Area for page 1 - is different from others due to Table headers
    area_2 = (135, 10, 610, 780)  # Area for page 2 onwards (can just be adjusted as needed)

    # Extract tables for page 1 using area_1
    tables_page_1 = tabula.read_pdf(pdf_path, pages="1", area=area_1,
                                    multiple_tables=True, lattice=True, guess=False)

    # Extract tables for pages 2 onwards using area_2
    tables_page_2_onwards = tabula.read_pdf(pdf_path, pages=page_range, area=area_2,
                                            multiple_tables=True, lattice=True, guess=False)

    # Combine the tables for both page 1 and pages 2 onwards
    tables = tables_page_1 + tables_page_2_onwards

    if not tables:
        print("No tables found in the PDF.")
        return

    # Convert the extracted tables into a single Excel file
    with pd.ExcelWriter(excel_path, engine='openpyxl') as writer:
        for i, table in enumerate(tables):
            table_name = f"Page {i+1}"

            # Remove the first 3 rows for sheets #2 onwards
            if i >= 1:  # Starting from sheet #2 (index 1)
                table = table.iloc[2:].reset_index(drop=True)

            # # Set the first row of the remaining table as the header
            # table.columns = table.iloc[0]  # Set first row as header
            # table = table.drop(0).reset_index(drop=True)  # Remove the new header row (it was already set)

            table.to_excel(writer, sheet_name=table_name, index=False)
            print(f"Table {i+1} written to sheet '{table_name}'")

            # Get the worksheet object from the writer
            worksheet = writer.sheets[table_name]

            # Autofit columns for each sheet
            for col_num, column in enumerate(table.columns):
                max_len = max(table[column].apply(lambda x: len(str(x))).max(),
                              len(column))  # max length between data and header
                worksheet.column_dimensions[
                    openpyxl.utils.get_column_letter(col_num + 1)].width = max_len + 2  # Add some padding

    print(f"Tables have been successfully written to '{excel_path}'.")

# Example Usage
pdf_path = 'test2.pdf'   # Path to your PDF file
excel_path = 'test2.xlsx'  # Path to save the Excel file

extract_tables_from_pdf(pdf_path, excel_path)


# ***** COMBINING EACH TABLE INTO THE FIRST SHEET ***** NOTE: WORK IN PROGRESS!!!
# df = pd.read_excel(excel_path, sheet_name=0)
#
# # Read the rest of the sheets and append them to the first one
# excel_file = pd.ExcelFile(excel_path)
# for sheet_name in excel_file.sheet_names[1:]:
#     # Read each sheet
#     temp_df = pd.read_excel(excel_path, sheet_name=sheet_name)
#     # Append the current sheet data to the main dataframe
#     df = pd.concat([df, temp_df], ignore_index=True)
#
# # Save the concatenated DataFrame to a new Excel file
# df.to_excel(excel_path, index=False)
#
# print(f"Sheets combined and saved as '{excel_path}'.")
