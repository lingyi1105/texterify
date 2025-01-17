import { Button, Empty, message, Modal, Table } from "antd";
import * as React from "react";
import { ExportConfigsAPI, IGetExportConfigsResponse } from "../api/v1/ExportConfigsAPI";
import { IGetLanguagesOptions, ILanguage } from "../api/v1/LanguagesAPI";
import { IProject } from "../api/v1/ProjectsAPI";
import { PermissionUtils } from "../utilities/PermissionUtils";
import { DEFAULT_PAGE_SIZE, PAGE_SIZE_OPTIONS } from "./Config";

export function ExportConfigsTable(props: { project: IProject; tableReloader?: number; style?: React.CSSProperties }) {
    const [page, setPage] = React.useState<number>(1);
    const [perPage, setPerPage] = React.useState<number>(DEFAULT_PAGE_SIZE);
    const [selectedRowKeys, setSelectedRowKeys] = React.useState<React.Key[]>([]);
    const [dialogVisible, setDialogVisible] = React.useState<boolean>(false);
    const [languageToEdit, setLanguageToEdit] = React.useState<ILanguage>(null);
    const [exportConfigResponse, setExportConfigResponse] = React.useState<IGetExportConfigsResponse>(null);
    const [exportConfigsLoading, setLanguagesLoading] = React.useState<boolean>(false);
    const [isDeleting, setIsDeleting] = React.useState<boolean>(false);

    async function reload(options?: IGetLanguagesOptions) {
        setLanguagesLoading(true);

        try {
            const newExportConfigsResponse = await ExportConfigsAPI.getExportConfigs({
                projectId: props.project.id,
                options: options
            });
            setExportConfigResponse(newExportConfigsResponse);
        } catch (error) {
            console.error(error);
            message.error("Failed to load export targets.");
        }

        setLanguagesLoading(false);
    }

    React.useEffect(() => {
        (async () => {
            await reload();
        })();
    }, [props.tableReloader]);

    function getRows() {
        if (!exportConfigResponse) {
            return [];
        }

        return exportConfigResponse.data.map((exportConfig) => {
            return {
                key: exportConfig.id,
                fileFormat: exportConfig.attributes.file_format,
                filePath: exportConfig.attributes.file_path,
                defaultLanguageFilePath: exportConfig.attributes.default_language_file_path,
                controls: (
                    <div style={{ display: "flex", justifyContent: "center" }}>
                        <Button
                            onClick={() => {
                                // setLanguageToEdit(language);
                                setDialogVisible(true);
                            }}
                        >
                            Edit
                        </Button>
                    </div>
                )
            };
        }, []);
    }

    function getColumns() {
        const columns: { title: string; dataIndex: string; key?: string; width?: number }[] = [
            {
                title: "File format",
                dataIndex: "fileFormat",
                key: "fileFormat"
            },
            {
                title: "File path",
                dataIndex: "filePath",
                key: "filePath"
            },
            {
                title: "Default language file path",
                dataIndex: "defaultLanguageFilePath",
                key: "defaultLanguageFilePath"
            }
        ];

        if (PermissionUtils.isDeveloperOrHigher(props.project.attributes.current_user_role)) {
            columns.push({
                title: "",
                dataIndex: "controls",
                width: 50
            });
        }

        return columns;
    }

    async function onDelete() {
        setIsDeleting(true);
        Modal.confirm({
            title: "Do you really want to delete the selected export targets?",
            content: "This cannot be undone and all translations for this export target will also be deleted.",
            okText: "Yes",
            okButtonProps: {
                danger: true
            },
            cancelText: "No",
            autoFocusButton: "cancel",
            visible: isDeleting,
            onOk: async () => {
                try {
                    const response = await ExportConfigsAPI.deleteExportConfigs({
                        projectId: props.project.id,
                        exportConfigIds: selectedRowKeys as string[]
                    });
                    if (response.errors) {
                        message.error("Failed to delete export target.");
                        return;
                    }
                } catch (error) {
                    message.error("Failed to delete export target.");
                    console.error(error);
                }

                await reload();

                setIsDeleting(false);
                setSelectedRowKeys([]);
            },
            onCancel: () => {
                setIsDeleting(false);
            }
        });
    }

    return (
        <div style={{ display: "flex", flexDirection: "column", minWidth: 0 }}>
            <Button
                danger
                onClick={onDelete}
                disabled={
                    selectedRowKeys.length === 0 ||
                    !PermissionUtils.isDeveloperOrHigher(props.project.attributes.current_user_role)
                }
                loading={isDeleting}
                style={{ marginBottom: 24, alignSelf: "flex-start" }}
            >
                Delete selected
            </Button>
            <Table
                style={props.style}
                rowSelection={{
                    onChange: (newSelectedRowKeys) => {
                        setSelectedRowKeys(newSelectedRowKeys);
                    },
                    getCheckboxProps: () => {
                        return {
                            disabled: !PermissionUtils.isDeveloperOrHigher(props.project.attributes.current_user_role)
                        };
                    }
                }}
                dataSource={getRows()}
                columns={getColumns()}
                bordered
                loading={exportConfigsLoading}
                pagination={{
                    pageSizeOptions: PAGE_SIZE_OPTIONS,
                    showSizeChanger: true,
                    current: page,
                    pageSize: perPage,
                    total: exportConfigResponse?.meta?.total || 0,
                    onChange: async (newPage, newPerPage) => {
                        const isPageSizeChange = perPage !== newPerPage;

                        if (isPageSizeChange) {
                            setPage(1);
                            setPerPage(newPerPage);
                            reload({ page: 1, perPage: newPerPage });
                        } else {
                            setPage(newPage);
                            reload({ page: newPage });
                        }
                    }
                }}
                locale={{
                    emptyText: <Empty description="No export targets found" image={Empty.PRESENTED_IMAGE_SIMPLE} />
                }}
            />

            {/* <AddEditLanguageFormModal
                visible={dialogVisible}
                onCancelRequest={() => {
                    setDialogVisible(false);
                    setLanguageToEdit(null);
                }}
                languageFormProps={{
                    projectId: props.project.id,
                    languageToEdit: languageToEdit,

                    onCreated: async () => {
                        setDialogVisible(false);
                        setLanguageToEdit(null);
                        reload();
                    }
                }}
            /> */}
        </div>
    );
}
